#!/usr/bin/env python3
"""EL CONTENIDO de la web de esta ROM: lo unico que es de este juego.

jekyll.py y make_web.py son la maquinaria y no llevan dentro el nombre de
ningun juego: lo leen de aqui.

Todas las cifras de aqui estan medidas sobre esta ROM, con las herramientas
de tools/: CODIGO y DATOS los imprime tools/presupuesto.py (make sanity),
INSTRUCCIONES, COMENTARIOS y RUTINAS los da tools/densidad.py (make densidad:
"de N" rutinas, "N instrucciones, M comentarios").
"""

NOMBRE = "Shindobaddo Nanatsu no Bouken"
EDITOR = "Casio"
ANIO = 1986
REPOSITORIO = "https://github.com/antxiko/Shindobaddo-disassembly"
SHA1 = "d120ca303c3e1dd56adee68f10e9e1ab51f50ab3"

CODIGO = 10686
DATOS = 5698
RUTINAS = 639
INSTRUCCIONES = 5443
COMENTARIOS = 2218


def densidad(idioma):
    """El porcentaje comentado, con la coma o el punto de cada idioma."""
    d = "%.1f" % (100.0 * COMENTARIOS / INSTRUCCIONES)
    return d.replace(".", ",") if idioma == "es" else d


PIE_LEGAL = {
    "es": "<em>Shindobaddo Nanatsu no Bouken</em> es un juego de Casio para MSX, de 1986, en un cartucho de 16 KB. "
          "Todos los derechos sobre el juego siguen siendo de sus titulares. Este trabajo es de "
          "preservaci&oacute;n, estudio y documentaci&oacute;n, y la imagen de la ROM no se distribuye.",
    "en": "<em>Shindobaddo Nanatsu no Bouken</em> is a 1986 Casio game for the MSX, on a 16 KB cartridge. All "
          "rights in the game remain with their holders. This is preservation, study and documentation work, and "
          "the ROM image is not distributed.",
}

PORTADA = {
    "es": dict(
        titulo="Shindobaddo Nanatsu no Bouken - desensamblado comentado",
        claim="Simbad recorre siete islas de plataformas y escaleras, derriba a sus enemigos con el alfanje o con "
              "un salto mortal y, cuando ha derribado a los que abren la isla, busca la salida; un p&aacute;jaro "
              "gigante lo lleva de isla en isla. Todo el juego corre en la interrupci&oacute;n. El t&iacute;tulo "
              "sale de ejecutar la ROM, cotejado con openMSX; las siete islas, de la RAM grabada; la partida en GIF "
              "y las m&uacute;sicas de su propio motor, id&eacute;nticas a openMSX cuadro a cuadro.",
        ficha=["Casio - <b>(c) 1986</b>",
               "Cartucho de <b>16 KB</b> en 0x4000",
               "<b>MSX</b>", "Volcado <b>d120ca30...</b>"],
        aviso="<b>Aqu&iacute; no hay capturas del juego.</b> El t&iacute;tulo sale de ejecutar la ROM (cotejado "
              "con openMSX), las islas las monta el c&oacute;digo de la ROM en la RAM y los GIF son la ROM "
              "<b>funcionando en openMSX</b>: en cada cuadro se apuntan la VRAM, la RAM y los registros del VDP, "
              "y <b>c&oacute;digo nuestro los pinta</b>.",
    ),
    "en": dict(
        titulo="Shindobaddo Nanatsu no Bouken - commented disassembly",
        claim="Sindbad crosses seven islands of platforms and ladders, knocks his enemies down with his scimitar or "
              "with a somersault and, once he has felled the ones that open the island, looks for the way out; a "
              "giant bird carries him from island to island. The whole game runs in the interrupt. The title comes "
              "from running the ROM, checked against openMSX; the seven islands, from the recorded RAM; the game in "
              "GIF and the tunes from its own engine, identical to openMSX frame by frame.",
        ficha=["Casio - <b>(c) 1986</b>",
               "<b>16 KB</b> cartridge at 0x4000",
               "<b>MSX</b>", "Dump <b>d120ca30...</b>"],
        aviso="<b>There are no screenshots of the game here.</b> The title comes from running the ROM (checked "
              "against openMSX), the islands are built in RAM by the ROM's code and the GIFs are the ROM "
              "<b>running in openMSX</b>: on every frame the VRAM, the RAM and the VDP registers are logged, and "
              "<b>our own code paints them</b>.",
    ),
}

PAGINAS = [
    [("THE-GAME.html", "LA-PARTIDA.html", "The game", "La partida",
      "the intro, the title, the controls, the scimitar and the somersault, the power, the lives and the points",
      "la presentaci&oacute;n, el t&iacute;tulo, los mandos, el alfanje y el salto mortal, la fuerza, las vidas "
      "y los puntos"),
     ("THE-ISLANDS.html", "LAS-ISLAS.html", "The islands", "Las islas",
      "the seven islands whole, how they are built, the enemies, the way out and the bird",
      "las siete islas enteras, c&oacute;mo se montan, los enemigos, la salida y el p&aacute;jaro"),
     ("THE-TEXTS.html", "LOS-TEXTOS.html", "The texts", "Los textos",
      "every text in the ROM, with its translation",
      "todos los textos de la ROM, con su traducci&oacute;n"),
     ("THE-MUSIC.html", "LA-MUSICA.html", "The music", "La m&uacute;sica",
      "the five tunes, from its own sound engine and checked against openMSX",
      "las cinco m&uacute;sicas, de su propio motor de sonido y cotejadas con openMSX")],
    [("CURIOSITIES.html", "CURIOSIDADES.html", "Curiosities", "Curiosidades",
      "keys at power-on: endless lives and the starting island, the game in the interrupt, jumps into the middle "
      "of instructions and code nobody calls",
      "las teclas al encender: vidas sin fin y la isla de salida, el juego en la interrupci&oacute;n, saltos a "
      "mitad de una instrucci&oacute;n y c&oacute;digo que nadie llama")],
    [("UNDER-THE-HOOD.html", "POR-DENTRO.html", "Under the hood", "Por dentro",
      "rebuilding the ROM, the BIOS it uses, the states, the RAM and the tools",
      "rehacer la ROM, la BIOS que usa, los estados, la RAM y las herramientas")],
]

# Repositorio nuevo: no hay paginas viejas que redirigir.
VIEJAS = {}

LOGOTIPO = "logotipo.png"
