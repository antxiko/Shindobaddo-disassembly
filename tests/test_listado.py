"""Lo que se afirma de la ROM, comprobado contra sus bytes.

Corre con la ROM delante y sin ella: cuando no esta, la imagen se rehace desde
las filas defb/defw del listado, que si viaja con el repositorio. Sin la ROM
solo se comprueba lo que cae en datos.
"""

import os
import re
import subprocess
import sys
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(RAIZ, "tools"))

ROM = os.path.join(RAIZ, "sindbad.rom")
ASM = os.path.join(RAIZ, "src", "sindbad.asm")
NOTAS = os.path.join(RAIZ, "src", "sindbad.notes")
ORG = 0x4000
TAM = 16384

FILA = re.compile(r"^\s+def(b|w)\s+([0-9a-fA-F,h ]+)\s*;\s*([0-9a-f]{4})")


def imagen_desde_el_listado():
    img = bytearray(TAM)
    with open(ASM, encoding="utf-8") as f:
        for ln in f:
            m = FILA.match(ln)
            if not m:
                continue
            ancho, cuerpo, dirr = m.group(1), m.group(2), int(m.group(3), 16)
            p = dirr - ORG
            for tok in cuerpo.split(","):
                tok = tok.strip().rstrip("h")
                if not tok:
                    continue
                v = int(tok, 16)
                if ancho == "b":
                    img[p] = v
                    p += 1
                else:
                    img[p] = v & 0xFF
                    img[p + 1] = v >> 8
                    p += 2
    return bytes(img)


def lee():
    if os.path.exists(ROM):
        with open(ROM, "rb") as f:
            return f.read()
    return imagen_desde_el_listado()


def b(a):
    return lee()[a - ORG]


def w(a):
    rom = lee()
    return rom[a - ORG] | (rom[a - ORG + 1] << 8)


def instruccion(dirr):
    """La instruccion del listado en esa direccion (sin el comentario)."""
    with open(ASM, encoding="utf-8") as f:
        for ln in f:
            m = re.match(r"^\t(\S.*?)\s*;([0-9a-f]{4})", ln)
            if m and int(m.group(2), 16) == dirr:
                return m.group(1).replace("\t", " ").strip()
class Cabecera(unittest.TestCase):
    def test_ab_e_init_en_0x4010(self):
        rom = lee()
        self.assertEqual(rom[:2], b"AB")
        self.assertEqual(w(0x4002), 0x4010)
        self.assertEqual(rom[4:16], bytes(12))

    def test_son_16_kb(self):
        self.assertEqual(len(lee()), TAM)


class LaInterrupcion(unittest.TestCase):
    def test_va_por_h_keyi(self):
        self.assertEqual([instruccion(a) for a in (0x4035, 0x4038, 0x403B, 0x403D)],
                         ["ld hl,interrupcion", "ld (0fd9bh),hl", "ld a,0c3h", "ld (0fd9ah),a"])

    def test_el_bucle_principal_esta_vacio(self):
        self.assertEqual(instruccion(0x4040), "jr bucle_vacio")

    def test_ocho_estados_generales(self):
        for k in range(8):
            self.assertTrue(0x4000 <= w(0x453D + 2 * k) < 0x8000)


def bios(a, n):
    """Texto en las casillas de las letras de la BIOS (0x80 + letra - 0x30)."""
    return "".join(" " if c in (0, 0x20) else chr(c - 0x80 + 0x30) for c in lee()[a - ORG:a - ORG + n])


class LosTextos(unittest.TestCase):
    def test_ronda_e_isla(self):
        self.assertEqual(bios(0x4AA9, 6), "ROUND ")
        self.assertEqual(bios(0x4AAF, 7), "ISLAND ")

    def test_game_over(self):
        self.assertEqual(bios(0x4B18, 9), "GAME OVER")


class LasTeclasAlEncender(unittest.TestCase):
    def test_la_fila_0_del_teclado_en_0xe000(self):
        self.assertEqual([instruccion(a) for a in (0x4026, 0x4027, 0x402A, 0x402B, 0x402C)],
                         ["xor a", "call 00141h", "rrca", "cpl", "ld (0e000h),a"])

    def test_teclas_1_a_3_la_isla_de_salida(self):
        self.assertEqual([instruccion(a) for a in (0x4103, 0x4106, 0x4108, 0x4109)],
                         ["ld a,(0e000h)", "and 007h", "inc a", "cp 008h"])

    def test_tecla_0_vidas_sin_fin(self):
        self.assertEqual([instruccion(a) for a in (0x5DAD, 0x5DB0, 0x5DB2)],
                         ["ld a,(0e000h)", "and 080h", "ret nz"])


class Sonido(unittest.TestCase):
    def test_las_16_notas(self):
        self.assertEqual(w(0x7E79), 0x357)
        self.assertEqual(w(0x7E79 + 2 * 15), 0x7F)

    def test_once_sonidos_en_a_y_cuatro_en_b(self):
        for k in range(15):
            self.assertTrue(0x7A73 <= w(0x7AA8 + 2 * k) < 0x7E79)

    def test_seis_musicas_por_voz(self):
        rom = lee()
        for ini, fin in ((0x7E99, 0x7EC1), (0x7EC1, 0x7EF9)):
            finales = sum(1 for a in range(ini, fin, 2) if w(a) == 0xFFFF)
            self.assertEqual(finales, 6)


class ElListado(unittest.TestCase):
    def test_densidad_y_flojas(self):
        salida = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "densidad.py"), ASM],
            capture_output=True, text=True, check=True).stdout
        m = re.search(r"(\d+) instrucciones, (\d+) comentarios", salida)
        self.assertGreaterEqual(int(m.group(2)) * 100, 40 * int(m.group(1)))
        self.assertIn("---- 0 rutinas por debajo del 10 %", salida)

    def test_ningun_call_sin_nombre(self):
        salida = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "sin_bautizar.py"), ASM],
            capture_output=True, text=True, check=True).stdout
        self.assertTrue(salida.startswith("0 rutinas sin bautizar"), salida[:200])

    def test_cada_comentario_en_su_instruccion(self):
        salida = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "valida_c.py"), ASM, NOTAS],
            capture_output=True, text=True, check=True).stdout
        self.assertIn("0 fuera de sitio, 0 repetidos", salida)


if __name__ == "__main__":
    unittest.main()
