#!/usr/bin/env python3
"""El protagonista, el pajaro grande y los enemigos de Shindobaddo MONTADOS DESDE LA ROM (ninguna imagen es una captura).

Shindobaddo carga los dibujos de sus sprites en 0x1800 (el registro 6 = 3) a trozos, empaquetados y con sus espejos, y
cambia los del protagonista segun lo que hace: `prota_dibujos` (0x61A0), `prota_sprite` (0x61E7). Aqui se EJECUTAN las
rutinas del juego con el Z80 de tools/bios.py: `prota_pinta` (0x6279) con cada dibujo (0xEAE5) y cada lado (0xEADE),
`pajaro_dibuja` (0x58EF) y `enemigos_pon` (0x6981), y se pinta lo que dejan en la VRAM: los atributos (0x3B00) y los
dibujos (0x1800), sprites de 16 x 16.

Los enemigos NO son sprites: son casillas que `pinta_objeto` (0x767B) copia en la pantalla con su clase (IY): el
dibujo de andar (+0, cuatro: el paso y el lado), el de caer (+2), el tamano (+5) y las columnas (+6).

  protagonista.png   andando (0xEAE5 = 0, los dos pasos), el golpe de alfanje (1, 2 y 3), en la escalera (5),
                     rebotando (7), cayendo (9) y muerto (10), a los dos lados; el alfanje es el sexto sprite (`espada`
                     0x6371, color 11)
  pajaro.png         el pajaro grande con las alas en sus dos dibujos (`pajaro_dibuja`: los dibujos 0 o + 0x2C cada 4
                     cuadros)
  enemigos.png       las clases 0x6C92 (2 x 2), 0x6D7F y 0x6D88 (3 x 2) con sus cuatro dibujos de andar y el de caer,
                     en los colores de la primera vuelta
  andar_cuadros.gif  el protagonista andando (el paso, 0xEB0A) y el golpe de alfanje (tres dibujos de 3 cuadros)

Uso: hojas.py docs/imagenes | hojas.py cotejo
"""
import os
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(RAIZ, "tools"))
import vdp          # noqa: E402

ORG = 0x4000
ROM = open(os.path.join(RAIZ, "sindbad.rom"), "rb").read()
FONDO = (40, 40, 48)
POSES = [(0, 0), (0, 2), (1, 0), (2, 0), (3, 0), (5, 0), (5, 1), (7, 0), (9, 0), (10, 0)]   # (0xEAE5, 0xEB0A)
CLASES = [0x6C92, 0x6D7F, 0x6D88]


def b(a):
    return ROM[a - ORG]


def maquina():
    from pantallas import Sindbad
    m = Sindbad(ROM, ORG)
    m.llama(0x4090)                 # partida_pon
    m.llama(0x40AA)                 # pantalla_pon: SCREEN 2
    m.vdp.vram[0x2000:0x3800] = bytes([0xF0]) * 0x1800     # los colores que deja el titulo (0x474F): las casillas
    #                                 0xEC-0xFF de los enemigos se quedan con ellos, blanco sobre transparente
    m.mem[0xE003] = 1               # la primera vuelta
    m.llama(0x6981)                 # enemigos_pon: los dibujos y colores de las casillas de los enemigos
    m.llama(0x61A0)                 # prota_dibujos
    return m


def prota(m, dibujo, paso, izq, espada=True, tocado=0):
    """Ejecuta prota_pinta con el dibujo, el paso y el lado; devuelve los sprites (y, x, n, color) y los dibujos. Con
    0xEAE1 (tocado), `prota_vram` (0x63AC) esconde tres de los seis (Y 0xD1)."""
    m.mem[0xEAE5] = dibujo
    m.mem[0xEB0A] = paso
    m.mem[0xEADE] = 0x80 if izq else 0
    m.mem[0xEADD], m.mem[0xEAE1], m.mem[0xEAD1], m.mem[0xEADC] = 10, tocado, 0, 10
    m.mem[0xEAE7] = 0 if espada else 1
    m.llama(0x6279)
    return sat(m.vdp.vram, 0x3B04)[:6], bytes(m.vdp.vram[0x1800:0x2000])      # prota_vram: seis sprites


def sat(v, desde):
    out = []
    for k in range(32):
        y, x, n, c = v[desde + 4 * k:desde + 4 * k + 4]
        if y == 0xD0:
            break
        out.append((y, x, n, c))
    return out


def pinta(im, pat, n, x, y, color, escala=1):
    if color & 15 == 0:
        return
    n &= 0xFC
    d = pat[n * 8:n * 8 + 32]
    c = vdp.PALETA[color & 15]
    for fila in range(16):
        for col in range(16):
            if (d[fila + (16 if col >= 8 else 0)] >> (7 - (col & 7))) & 1:
                for ey in range(escala):
                    for ex in range(escala):
                        px, py = (x + col) * escala + ex, (y + fila) * escala + ey
                        if 0 <= px < im.width and 0 <= py < im.height:
                            im.putpixel((px, py), c)


def grupo(im, pat, sprites, x0, y0, E, ry, rx):
    """Los sprites del SAT, el primero encima, relativos a (ry, rx); con el bit EC (0x80 del color), X - 32."""
    for y, x, n, c in reversed(sprites):
        xx = x - (32 if c & 0x80 else 0)
        pinta(im, pat, n, x0 + xx - rx, y0 + ((y + 1) & 0xFF) - ry, c, E)


def casilla(im, v, n, x, y, E):
    for fila in range(8):
        p, c = v[n * 8 + fila], v[0x2000 + n * 8 + fila]
        for k in range(8):
            color = (c >> 4) if (p >> (7 - k)) & 1 else (c & 15)
            if color == 0:
                continue
            for ey in range(E):
                for ex in range(E):
                    im.putpixel(((x + k) * E + ex, (y + fila) * E + ey), vdp.PALETA[color])


def clase(c):
    """(dibujos de andar, dibujo de caer, tamano, columnas) de la clase IY."""
    anda = b(c) | b(c + 1) << 8
    cae = b(c + 2) | b(c + 3) << 8
    tam, cols = b(c + 5), b(c + 6)
    return [ROM[anda - ORG + tam * k:anda - ORG + tam * (k + 1)] for k in range(4)], ROM[cae - ORG:cae - ORG + tam], cols


def hoja(Image):
    m, E = maquina(), 3
    im = Image.new("RGB", (10 * 28 * E, 2 * 44 * E), FONDO)
    for fila, izq in enumerate((False, True)):
        for k, (d, p) in enumerate(POSES):
            spr, pat = prota(m, d, p, izq)
            grupo(im, pat, spr, 6 + 28 * k, 14 + 44 * fila, E, 10 * 8 + 1, 10 * 8)
    return im


def hoja_pajaro(Image):
    m, E = maquina(), 3
    m.llama(0x5879)                                     # pajaro_dibujos
    im = Image.new("RGB", (2 * 72 * E, 64 * E), FONDO)
    for k, alas in enumerate((0, 2)):
        m.mem[0xEAD1], m.mem[0xEAD8], m.mem[0xEADB] = 0, 16, (alas - 1) & 0xFF
        m.mem[0xEADD], m.mem[0xEAE5] = 12, 1
        m.llama(0x58EF)
        spr = [((y + 32) & 0xFF, x, n, c) for y, x, n, c in sat(m.vdp.vram, 0x3B00)]   # por si asoma por arriba
        grupo(im, bytes(m.vdp.vram[0x1800:0x2000]), spr, 4 + 72 * k, 4, E, min(s[0] for s in spr) + 1,
              min(s[1] for s in spr))
    return im


def hoja_enemigos(Image):
    m, E = maquina(), 4
    v = bytes(m.vdp.vram)
    im = Image.new("RGB", (5 * 24 * E, 3 * 32 * E), FONDO)
    for fila, c in enumerate(CLASES):
        andar, cae, cols = clase(c)
        for k, dib in enumerate(andar + [cae]):
            for j, n in enumerate(dib):
                casilla(im, v, n, 4 + 24 * k + 8 * (j % cols), 4 + 32 * fila + 8 * (j // cols), E)
    return im


def anima(Image):
    m, E, cuadros = maquina(), 3, []
    for izq in (False, True):
        for n in range(32):
            spr, pat = prota(m, 0, n // 4, izq)
            im = Image.new("RGB", (28 * E, 44 * E), FONDO)
            grupo(im, pat, spr, 6, 14, E, 10 * 8 + 1, 10 * 8)
            cuadros += [im]
        for d in (1, 2, 3):
            spr, pat = prota(m, d, 0, izq)
            im = Image.new("RGB", (28 * E, 44 * E), FONDO)
            grupo(im, pat, spr, 6, 14, E, 10 * 8 + 1, 10 * 8)
            cuadros += [im] * 3
    return cuadros


def guarda_gif(cuadros, ruta, ms=1000 / 60):
    imgs, durs = [], []
    for im in cuadros:
        if imgs and list(im.getdata()) == list(imgs[-1].getdata()):
            durs[-1] += ms
        else:
            imgs.append(im)
            durs.append(ms)
    imgs[0].save(ruta, save_all=True, append_images=imgs[1:], duration=[max(20, int(round(d))) for d in durs],
                 loop=0, disposal=1)


def otro_lado(clave):
    d, p, izq, espada, tocado = clave
    return d, p, 0 if izq else 0x80, espada, tocado


def cotejo():
    """Contra las grabaciones de openMSX (work/*.bin, la RAM 0xE000-0xF0FF):
    1) el protagonista: con el dibujo (0xEAE5), el paso (0xEB0A) y el lado (0xEADE) del cuadro, la ROM ejecutada aqui
       da los mismos sprites que la copia del juego (0xEB0B, 24 bytes: dy, dx, numero y color de los seis respecto
       al primero), y los dibujos de esos numeros en la VRAM grabada (0x1800) son los mismos que deja aqui;
    2) los dibujos y colores de las casillas 0x80-0xC7 de los enemigos (VRAM 0x0400-0x063F y 0x2400) en la primera
       vuelta (0xE003 = 1)."""
    m = maquina()
    v0 = bytes(m.vdp.vram)
    tot = dict(prota=0, prota_sin_cargar=0, prota_antes=0, prota_mal=0, casillas=0, casillas_titulo=0, casillas_otra_vuelta=0, casillas_mal=0)
    cache = {}
    for grab in ("atraccion", "partida", "caza", "final", "islas", "abierta"):
        ruta = os.path.join(RAIZ, "work", grab + ".bin")
        if not os.path.exists(ruta):
            continue
        for c in vdp.cuadros(ruta):
            v, ram = c["vram"], c["ram"]
            t = ram[0xB0B:0xB23]
            if t[0] < 0xC0 and ram[0xAE5] in (0, 1, 2, 3, 5, 6, 7, 9, 10) and t[2] | t[3]:
                clave = (ram[0xAE5], ram[0xB0A] & (2 if ram[0xAE5] == 0 else 1 if ram[0xAE5] == 5 else 0),
                         ram[0xADE] & 0x80, ram[0xAE7] == 0, int(ram[0xAE1] != 0))
                if clave not in cache:
                    cache[clave] = prota(m, *clave)
                spr, pat = cache[clave]
                hay = [tuple(t[4 * k:4 * k + 4]) for k in range(6) if t[4 * k] != 0xD0]
                hay = hay[:len(spr)]
                rel = lambda L: [(None if s[0] == 0xD1 else (s[0] - L[0][0]) & 0xFF, (s[1] - L[0][1]) & 0xFF, s[2],  # noqa: E731
                                  s[3]) for s in L]
                if rel(hay) == rel(spr):
                    usados = {s[2] & 0xFC for s in spr if s[3] & 15}
                    if all(v[0x1800 + n * 8:0x1800 + n * 8 + 32] == pat[n * 8:n * 8 + 32] for n in usados):
                        tot["prota"] += 1
                    else:
                        tot["prota_sin_cargar"] += 1        # el dibujo nuevo aun sin cargar en la VRAM
                elif any(rel(hay) == rel(o[0][:len(hay)]) for o in cache.values()) or                         rel(hay) == rel(prota(m, *otro_lado(clave))[0][:len(hay)]):
                    tot["prota_antes"] += 1     # compuesto antes de cambiar el dibujo o el lado (en los estados 8 y
                    #                             14, el pajaro y la vida menos, la tabla ni se recompone)
                else:
                    tot["prota_mal"] += 1
            if ram[0x003] == 1 and v[0x0400:0x0640] == v0[0x0400:0x0640]:
                if v[0x2400:0x2640] == v0[0x2400:0x2640]:
                    tot["casillas"] += 1
                elif {v[k] for k in range(0x2400, 0x2640) if v[k] != v0[k]} == {0xF0}:
                    tot["casillas_titulo"] += 1         # aun con los colores del titulo (0x474F), en la demostracion
                else:
                    tot["casillas_mal"] += 1
            elif ram[0x003] != 1 and v[0x0400:0x0640] == v0[0x0400:0x0640]:
                tot["casillas_otra_vuelta"] += 1
    return tot


def main(argv):
    if argv and argv[0] == "cotejo":
        print(cotejo())
        return 0
    from PIL import Image
    salida = argv[0]
    os.makedirs(salida, exist_ok=True)
    hoja(Image).save(os.path.join(salida, "protagonista.png"))
    hoja_pajaro(Image).save(os.path.join(salida, "pajaro.png"))
    hoja_enemigos(Image).save(os.path.join(salida, "enemigos.png"))
    guarda_gif(anima(Image), os.path.join(salida, "andar_cuadros.gif"))
    for f in ("protagonista.png", "pajaro.png", "enemigos.png", "andar_cuadros.gif"):
        print(f, os.path.getsize(os.path.join(salida, f)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
