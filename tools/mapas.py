#!/usr/bin/env python3
"""Las siete islas enteras, de la RAM grabada: el juego monta cada isla en 0xE01A (24 filas de 64 casillas,
isla_pon 0x4B21) y la pantalla ve 32 columnas desde la columna 0xEAD1 (fondo_pantalla 0x5645, desde la fila 2).
Se pinta la isla tal cual esta en la RAM al llegar el protagonista (el estado del protagonista 14, el pajaro
que lo trae, 2 cuadros despues de empezar: isla_pon ya la ha montado y aun no se mueve nada), filas 2-23, con los dibujos y colores de la VRAM de ese cuadro
(cada fila con los de su tercio). Lo que se ve son casillas: las cosas y los enemigos que ya estan son casillas
tambien; el protagonista y el pajaro son sprites y no salen.

La grabacion es work/islas.bin (tools/guiones/islas.tcl): la isla 7 elegida con las teclas al encender y las
demas FORZADAS por el guion.

Uso: mapas.py docs/imagenes
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vdp          # noqa: E402
from PIL import Image  # noqa: E402

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DESPUES = 2         # cuadros desde que el pajaro empieza a traerlo: la isla recien montada, sin objetos


def pinta(ram, vram):
    im = Image.new("RGB", (64 * 8, 22 * 8))
    px = im.load()
    for fila in range(2, 24):
        tercio = (fila // 8) * 0x800
        for col in range(64):
            t = ram[0x01A + fila * 64 + col]
            for r in range(8):
                p, c = vram[tercio + t * 8 + r], vram[0x2000 + tercio + t * 8 + r]
                for bit in range(8):
                    px[col * 8 + bit, (fila - 2) * 8 + r] = vdp.PALETA[(c >> 4) if p & (0x80 >> bit) else (c & 15)]
    return im


def coteja(ram, vram):
    """Las 22 filas de 32 que hay en la tabla de nombres (0x3840) contra la RAM desde la columna 0xEAD1."""
    col, mal = ram[0xAD1], 0
    for fila in range(2, 24):
        for x in range(32):
            if vram[0x3800 + fila * 32 + x] != ram[0x01A + fila * 64 + col + x]:
                mal += 1
    return mal


def main(salida):
    hechas, cuenta, distintas = {}, {}, {}
    for c in vdp.cuadros(os.path.join(RAIZ, "work", "islas.bin")):
        ram = c["ram"]
        isla = ram[0x002]
        if ram[0xAB1] == 0 and ram[0xAD3] == 14 and isla not in hechas:
            cuenta[isla] = cuenta.get(isla, 0) + 1
            if cuenta[isla] == DESPUES:
                hechas[isla] = pinta(ram, c["vram"])
                distintas[isla] = coteja(ram, c["vram"])
        if len(hechas) == 7:
            break
    for isla in sorted(hechas):
        ruta = os.path.join(salida, "isla%d.png" % isla)
        hechas[isla].save(ruta)
        print("%-10s %dx%d  la ventana de la pantalla contra la RAM: %d casillas distintas" % (
            os.path.basename(ruta), *hechas[isla].size, distintas[isla]))


if __name__ == "__main__":
    main(sys.argv[1])
