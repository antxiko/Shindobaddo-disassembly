# Curiosidades

## Las teclas al encender: vidas sin fin y la isla de salida

Al arrancar, el juego lee la fila 0 del teclado (las teclas 0 a 7), le da la vuelta y la guarda en 0xE000 (`init`,
0x4026): la tecla 0 va al bit 7 y las teclas 1 a 7 a los bits 0 a 6. Dos sitios la leen:

- **Las teclas 1, 2 y 3 eligen la isla de salida**, en binario, más uno (`partida_borra`, 0x4103): la tecla 1 es la
  isla 2, la 2 la isla 3, la 1 y la 2 la isla 4, la 3 la isla 5... y la 2 y la 3, la isla 7. Las tres darían 8, y
  entonces es la isla 1.
- **La tecla 0 da vidas sin fin**: antes de quitar una vida, el juego mira el bit 7 y, si está, no la quita
  (`vida_menos`, 0x5DAD). Tampoco le dan los tiros (0x79B0), ni el toque que se mira en 0x6178.

**Comprobado en openMSX** (`tools/guiones/islas.tcl`): con las teclas 0, 2 y 3 pulsadas al encender, 0xE000 vale
0x86 y la partida empieza en la isla 7; Simbad muere varias veces en la grabación y las cinco vidas siguen siendo
cinco. Ningún texto lo dice.

## Todo el juego en la interrupción

El programa principal es un `jr $` que salta a sí mismo para siempre (0x4040). Todo lo demás va en la interrupción
(el gancho H.KEYI): los mandos, Simbad, los enemigos, la pantalla, el estado y el sonido, en cada cuadro.

## Saltos a mitad de una instrucción

Para ahorrar unos bytes, algunos saltos caen en el segundo byte de una instrucción, que allí es otra:

| salto | cae en | allí es | para qué |
|---|---|---|---|
| 0x4130, 0x4150 | 0x413C, 0x415C | `res 0,(hl)` / `res 1,(hl)` dentro de un `ld bc` | el botón suelto |
| 0x417F | 0x41A2 | `ld a,7` dentro de un `ld hl` | la demostración anda a la izquierda |
| 0x5F33, 0x5F44 | 0x5F50 | `ld a,0x0D` dentro de un `ld hl` | la caída lo mata |
| 0x6108 | 0x6119 | `ld a,3` dentro de un `ld bc` | cuánto lo echa atrás un enemigo |
| 0x612B, 0x612F | 0x6134, 0x6137 | `ld (hl),5` / `ld (hl),0x0C` dentro de dos `ld hl` | la fila adonde lo echa |

## La demostración anda por sitios, no por tiempo

La demostración no lleva una lista de cuadros: cada entrada de su lista (0x41CB) es una columna. Simbad anda hacia
ella y, al llegar, hace lo que dice el segundo byte (la palanca y el botón), hasta que acaba el salto mortal o la
escalera (0xE00B).

## Borrar con la pila

Tres filas de la RAM de la isla se borran en cada cuadro con la **pila**: la rutina guarda SP, lo apunta al final
de las filas y hace 16 `push de` con dos blancos, seis veces (`pantalla_ram_borra`, 0x44EA).

## El pájaro en el borde izquierdo

El pájaro gigante son sprites, y los sprites no pueden asomar por la izquierda de la pantalla. Cuando está a menos
de 8 columnas del borde, el juego suma 32 a su X y pone el bit 7 del color (el bit EC, que corre el sprite 32
puntos a la izquierda), y así entra poco a poco (`pajaro_dibuja`, 0x58EF).

## La fuente de la BIOS en una dirección fija

El juego copia las letras desde la dirección 0x1D3F de la BIOS (`letras_bios`, 0x47E9): el "0" de la fuente, si
empieza en 0x1BBF como en la BIOS del MSX. No pregunta dónde está la fuente (CGTABL, 0x0004).

## Código que nadie llama

Entre dos tablas hay 23 bytes de código (0x6D68) a los que no llega ningún salto ni ningún puntero de la ROM, y que
no se ejecutaron en ninguna grabación: copian 3 o 2 filas de dos casillas, como la rutina que copia 3 x 3 (0x4F67).
Hay también seis bytes (0x6BBB) a los que no apunta nada.
