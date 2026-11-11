"""Las pantallas de Shindobaddo.

  - el titulo: EJECUTANDO la ROM (tools/bios.py: el Z80 con la BIOS que usa): lo de la partida (0x4090), la
    pantalla de INIT (0x40AA) y el primer paso del titulo (0x471F). Las letras las copia el juego de la fuente de
    la BIOS (0x1D3F, desde el "0"): aqui salen de la VRAM que grabo openMSX con C-BIOS;
  - logotipo.png, la cabecera de la web: el recuadro verde del titulo con el nombre en kana y kanji.

El titulo se coteja con la VRAM grabada (work/atraccion.bin): el primer cuadro con el titulo en la tabla de
nombres y la pantalla encendida. De ese cuadro salen tambien las letras de la fuente.

Uso: pantallas.py <dir> [cotejo]
"""
import os
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
import vdp                  # noqa: E402
from bios import Msx        # noqa: E402

RAIZ = os.path.dirname(AQUI)
CUADRO_TITULO = 400         # work/atraccion.bin: el estado 2 (el titulo) va de 301 a 557


def cuadro(grab, n):
    for i, c in enumerate(vdp.cuadros(os.path.join(RAIZ, "work", grab + ".bin"))):
        if i == n:
            return c


class Sindbad(Msx):
    """INIGRP como la BIOS: los registros salen de GRPNAM, GRPCOL, GRPCGP, GRPATR y GRPPAT (0xF3C7), que el juego
    pone antes (0x40AE: nombres 0x3800, colores 0x2000, dibujos 0, atributos 0x3B00, sprites 0x1800)."""
    def _bios(self):
        if self.pc == 0x0072:
            w = lambda a: self.mem[a] | self.mem[a + 1] << 8
            nam, col, cgp, atr, pat = (w(0xF3C7 + 2 * k) for k in range(5))
            v = self.vdp
            v.regs[:] = bytes([0x02, 0xE0, nam >> 10, (col >> 6) | 0x7F, (cgp >> 11) | 0x03, atr >> 7, pat >> 11,
                               self.mem[0xF3E9] << 4 | self.mem[0xF3EB]])
            v.vram[nam:nam + 0x300] = bytes(range(256)) * 3
            v.vram[cgp:cgp + 0x1800] = bytes(0x1800)
            v.vram[col:col + 0x1800] = bytes([self.mem[0xF3E9] << 4 | self.mem[0xF3EA]]) * 0x1800
            self.pc = self._pop()
            return
        super()._bios()


def fuente_de_la_vram():
    """Las letras "0" a "_" (0x30-0x5F): las casillas 0x80-0xAF del segundo tercio de la VRAM grabada, que el
    juego copio de la fuente de la BIOS; puestas en su sitio de una fuente de 2 KB."""
    v = cuadro("atraccion", CUADRO_TITULO)["vram"]
    f = bytearray(0x800)
    f[0x180:0x300] = v[0x0C00:0x0D80]
    return bytes(f)


def titulo(fuente):
    rom = open(os.path.join(RAIZ, "sindbad.rom"), "rb").read()
    m = Sindbad(rom, 0x4000)
    m.mem[0x1BBF:0x1BBF + 0x800] = fuente
    m.llama(0x4090)                 # partida_pon: el record a 5000
    m.llama(0x40AA)                 # pantalla_pon: SCREEN 2
    m.mem[0xEAB3] = 0
    m.llama(0x471F)                 # titulo, el paso 0
    return bytes(m.vdp.vram), bytes(m.vdp.regs)


def cotejo(v, regs):
    c = cuadro("atraccion", CUADRO_TITULO)
    t1, t2 = vdp.tela(v, regs, False), vdp.tela(c["vram"], c["regs"], False)
    puntos = sum(1 for y in range(192) for x in range(256) if t1[y][x] != t2[y][x])
    print("titulo contra atraccion/%d: puntos distintos %d de 49152; registros %s"
          % (CUADRO_TITULO, puntos,
             "iguales" if regs == bytes(c["regs"]) else "%s / %s" % (regs.hex(), bytes(c["regs"]).hex())))
    return puntos


def main(argv):
    v, regs = titulo(fuente_de_la_vram())
    vdp.imagen(v, regs, 2, con_sprites=False).save(os.path.join(argv[0], "titulo.png"))
    # el recuadro verde: filas 2-10, columnas 6-26
    vdp.imagen(v, regs, 4, con_sprites=False).crop((6 * 32, 2 * 32, 27 * 32, 11 * 32)).save(
        os.path.join(argv[0], "logotipo.png"))
    if len(argv) > 1:
        cotejo(v, regs)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
