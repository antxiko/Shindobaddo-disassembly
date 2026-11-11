#!/usr/bin/env python3
"""Los GIF de la web: tramos de las grabaciones de openMSX (tools/guiones/*.tcl, grabados con
tools/lanza_graba.ps1 en C-BIOS_MSX1_JP, -bp 0x4042 -ram "0xE000 0x1100"), pintados con tools/vdp.py.

Los tramos salen de la RAM grabada (work/resumen.py): 0xEAB1 el estado general, 0xEAD3 el del protagonista,
0xE002 la isla, 0xEAD7 la fuerza, 0xEAE3 las vidas, 0xEC25 la musica, 0xEC10 el sonido del canal B.

  atraccion  sin tocar nada: la presentacion de CASIO, el titulo y la demostracion
  partida    un jugador al azar en la isla 1: cinco vidas perdidas y GAME OVER
  caza       con la tecla 0 al encender; un jugador que busca a los enemigos de su fila y les da con el alfanje
  final      con la tecla 0 pulsada al encender (no se pierden vidas); 300 cuadros al azar y, FORZADO, la meta
             tocada (0xEAE4 = 0xFF): el pajaro, la cuenta de la fuerza, el cartel y la isla 2

Uso: gifs.py docs/imagenes
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vdp          # noqa: E402

# (fichero, grabacion, desde, hasta, cada)
TRAMOS = [
    ("casio.gif", "atraccion", 1, 300, 2),              # la presentacion: cuatro CASIO que se juntan
    ("demo.gif", "atraccion", 938, 1236, 2),            # la demostracion: anda, sube, le dan y muere
    ("cartel.gif", "final", 1716, 1975, 2),             # ROUND e ISLAND: el pajaro lleva a Simbad
    ("llegada.gif", "final", 1975, 2104, 2),            # el pajaro lo deja en la isla
    ("alfanje.gif", "caza", 796, 1000, 2),              # el alfanje: los enemigos que alcanza caen
    ("salto.gif", "partida", 848, 900, 2),              # el salto mortal en arco (el boton 2)
    ("tiro.gif", "final", 2120, 2230, 2),               # un enemigo le toca y una planta dispara
    ("final.gif", "final", 1268, 1716, 2),              # la meta: el pajaro se lo lleva y la fuerza se cuenta
    ("game_over.gif", "partida", 2430, 2720, 2),        # la ultima vida y GAME OVER
]


def main(salida):
    raiz = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    for fichero, grab, desde, hasta, cada in TRAMOS:
        n, s = vdp.gif(os.path.join(raiz, "work", grab + ".bin"),
                       os.path.join(salida, fichero), desde, hasta, cada=cada, tope_ms=4000)
        print("%-20s %4d imagenes, %5.1f s, %8d bytes" % (
            fichero, n, s, os.path.getsize(os.path.join(salida, fichero))))


if __name__ == "__main__":
    main(sys.argv[1])
