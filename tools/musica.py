#!/usr/bin/env python3
"""Las musicas de Shindobaddo, EJECUTANDO su propio motor de sonido (ver motor_musica.py).

El motor va en `sonido` (0x7A73), una vez por cuadro desde la interrupcion: los efectos de los canales A (0xEC0D)
y B (0xEC10) y las dos voces de la musica, la primera en el canal B (su numero en 0xEC25, la lista 0x7E99) y la
segunda en el C (0xEC30, la lista 0x7EC1). No hay rutina de peticion: el juego escribe el mismo numero en los
dos sitios. Aqui se escriben igual, sin efectos, y se corre 0x7A73 cuadro a cuadro; el motor llega al PSG por la
BIOS (WRTPSG, y RDPSG para el mezclador y para bajar el volumen), que se atrapa. Ninguna musica vuelve a empezar:
todas acaban en 0xFFFF y el motor pone los dos numeros a 0. La 2 (la cuenta) solo la pide en la primera voz.

Uso:  musica.py registros N [cuadros] | mp3 N f.mp3 | todas docs/audio | cotejo
"""
import hashlib
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import motor_musica  # noqa: E402

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# (numero, fichero, quien la pide)
MUSICAS = [
    (1, "musica_llegada.mp3", "el pajaro deja a Simbad en la isla (0x56E7)"),
    (2, "(la cuenta)", "la cuenta de la fuerza al acabar la isla, una vez por punto (0x5843): 8 cuadros, sin MP3"),
    (3, "musica_cartel.mp3", "el cartel ROUND / ISLAND: el pajaro lleva a Simbad (0x56B3)"),
    (4, "musica_meta.mp3", "la meta: el pajaro viene a por Simbad (0x577F, 0x57A2, 0x6192)"),
    (5, "musica_game_over.mp3", "GAME OVER (0x4ABE)"),
    (6, "musica_isla_abierta.mp3", "todas las cosas cogidas: la isla se abre (0x5C28)"),
]
SOLO_B = (2,)                     # la cuenta (0x5843) solo escribe 0xEC25: la voz del canal C calla
VOCES = (0xEC25, 0xEC3B)          # los dos bloques de 11 bytes de las voces


def cfg(numero):
    return dict(rom="sindbad.rom", org=0x4000, sp=0xF380, frame=0x7A73,
                pistas={numero: [("b", 0xEC25, numero)] + ([] if numero in SOLO_B else [("b", 0xEC30, numero)])},
                ram=VOCES, hz=60, max_s=120, cuadros_previos=0)


def rom():
    return open(os.path.join(RAIZ, "sindbad.rom"), "rb").read()


def ejecuta(numero, maximo=None):
    c = cfg(numero)
    maximo = maximo or c["hz"] * c["max_s"]
    z = motor_musica.arranca(c, rom(), numero)
    a, b = c["ram"]
    cuadros, vistos = [], {}
    for k in range(maximo):
        cuadros.append(motor_musica.cuadro(z))
        h = hashlib.sha1(bytes(z.mem[a:b])).digest()
        if h in vistos:
            return cuadros, (None if vistos[h] == k else vistos[h])
        vistos[h] = k + 1
        if z.mem[0xEC25] == 0 and z.mem[0xEC30] == 0:
            return cuadros, None
    return cuadros, None


def mp3(numero, ruta):
    hz = 60
    cuadros, vuelta = ejecuta(numero)
    todo, fundido = motor_musica.desarrolla(cuadros, vuelta, hz)
    motor_musica.a_mp3(motor_musica.sintetiza(todo, hz), ruta, fundido, hz)
    print("%-26s %d cuadros (%.1f s), vuelve al %s" % (os.path.basename(ruta), len(cuadros),
                                                      len(cuadros) / hz, vuelta))


def estados(numero, maximo, inicio, siembra=None):
    """Cada cuadro del motor ejecutado: la RAM de las voces y los registros del PSG (desde los de `inicio`).
    `siembra`: la RAM del sonido (0xEC0D-0xEC3A) como la tenia el juego en ese cuadro."""
    c = cfg(numero)
    z = motor_musica.arranca(c, rom(), numero)
    if siembra:
        z.mem[0xEC0D:0xEC3B] = siembra
    for r in range(16):                 # el PSG como estaba: RDPSG lo lee para bajar el volumen
        z.maq.psg[r] = inicio[r]
    a, b = c["ram"]
    regs = list(inicio)
    out = [(bytes(z.mem[a:b]), tuple(regs))]
    for _ in range(maximo):
        for r, v in motor_musica.cuadro(z):
            if r < 16:
                regs[r] = v
        out.append((bytes(z.mem[a:b]), tuple(regs)))
    return out


def cotejo():
    """Los tonos y los volumenes del motor ejecutado contra los del PSG que grabo openMSX al entrar en cada
    interrupcion (work/*.bin, con la RAM 0xE000-0xF0FF). La musica empieza en el cuadro en que 0xEC25 pasa a ser
    su numero; el motor arranca con la RAM del sonido (0xEC0D-0xEC3A) y el PSG de ese cuadro, y cada cuadro
    grabado se empareja con el cuadro del motor que tiene la MISMA RAM en las dos voces (0xEC25, 22 bytes). Se
    miran el canal B (registros 2, 3 y 9) y el C (4, 5 y 10) mientras el numero sigue siendo el suyo; el canal B,
    solo sin un efecto suyo sonando (0xEC10 a 0)."""
    import vdp
    out = []
    for grab in ("atraccion", "islas", "partida", "final", "abierta"):
        ruta = os.path.join(RAIZ, "work", grab + ".bin")
        if not os.path.exists(ruta):
            continue
        cs = list(vdp.cuadros(ruta, 0x1100))
        num = lambda k: cs[k]["ram"][0xC25]
        for numero, fichero, _ in MUSICAS:
            k0 = next((k for k in range(1, len(cs)) if num(k) == numero and num(k - 1) != numero), None)
            if k0 is None:
                continue
            emu = estados(numero, 60 * 60, cs[k0]["psg"], bytes(cs[k0]["ram"][0xC0D:0xC3B]))
            e, malos, mirados, sueltos = 0, [], 0, 0
            for j in range(k0 + 1, min(len(cs), k0 + 60 * 40)):
                ram = bytes(cs[j]["ram"][0xC25:0xC3B])
                if num(j) != numero:
                    break
                hallado = next((x for x in range(e, min(e + 8, len(emu))) if emu[x][0] == ram), None)
                if hallado is None:
                    sueltos += 1
                    continue
                e = hallado
                mirados += 1
                p, r = cs[j]["psg"], emu[e][1]
                mirar = ([] if cs[j]["ram"][0xC10] else [(2, 3, 9)]) + [(4, 5, 10)]

                def distinto(t, a, v):
                    if p[v] != r[v]:
                        return True
                    return bool(p[v] & 0x1F) and (p[t] != r[t] or (p[a] & 15) != (r[a] & 15))
                if any(distinto(*c) for c in mirar):
                    malos.append(j - k0)
            out.append((fichero, grab, k0, mirados, malos, sueltos))
    return out


def main(argv):
    if argv and argv[0] == "cotejo":
        for fichero, grab, k0, mirados, malos, sueltos in cotejo():
            print("%-26s %s, empieza en el cuadro %d: %d cuadros mirados, %d distintos %s; %d sin pareja"
                  % (fichero, grab, k0, mirados, len(malos), malos[:8], sueltos))
        return 0
    if argv and argv[0] == "todas":
        os.makedirs(argv[1], exist_ok=True)
        for numero, fichero, _ in MUSICAS:
            if fichero.endswith(".mp3"):
                mp3(numero, os.path.join(argv[1], fichero))
        return 0
    if argv and argv[0] == "mp3":
        mp3(int(argv[1]), argv[2])
        return 0
    if argv and argv[0] == "registros":
        cuadros, vuelta = ejecuta(int(argv[1]), int(argv[2]) if len(argv) > 2 else None)
        for i, escr in enumerate(cuadros):
            print("%5d %s" % (i, " ".join("%X=%02X" % rv for rv in escr)))
        print("cuadros: %d, vuelve al %s" % (len(cuadros), vuelta))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
