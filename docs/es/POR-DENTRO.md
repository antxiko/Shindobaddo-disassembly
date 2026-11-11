# Por dentro

## Rehacer la ROM

`make verify` ensambla `src/sindbad.asm` con pasmo y sale la ROM de 16 KB **byte a byte**. `make sanity` comprueba
lo que el reensamblado no cubre: que ningún byte declarado como datos se lea como código, que ningún punto de
entrada caiga en datos y que estén explicados los 16.384 bytes. `make test` pasa los tests. La ROM no está en el
repositorio: hay que ponerla en la raíz como `sindbad.rom` (el volcado de GoodMSX, `[!]`, sha1 `d120ca30...`).

| | bytes |
|---|---|
| código trazado | 10.686 |
| datos con nombre | 5.698 |
| sin explicar | 0 |

El listado tiene 2.218 comentarios en 5.443 instrucciones (40,7 %), 639 rutinas y etiquetas, ninguna por debajo del
10 % comentada, y ninguna rutina llamada sin nombre.

## El cartucho

16 KB en la **página 1** (0x4000-0x7FFF), con INIT en 0x4010. Lo que no es código: las casillas y los colores del
título, de las islas, de Simbad, del pájaro y de los enemigos (empaquetados con una máscara de bits por cada ocho
bytes, `desempaqueta`, 0x43D0), las listas de piezas de cada isla, las clases de los enemigos, los textos, los
efectos de sonido y la música.

## La BIOS que usa

INIGRP para SCREEN 2, con las direcciones de sus tablas escritas antes en GRPNAM y las demás (0x40AE); WRTVDP para
los registros del VDP; SETWRT y el puerto 0x98 directamente para escribir la VRAM (con una espera entre bytes), y
FILVRM, LDIRVM, LDIRMV y WRTVRM; DISSCR y ENASCR; GTSTCK, GTTRIG y SNSMAT para los mandos, KILBUF para vaciar el
buffer del teclado; WRTPSG, RDPSG y GICINI para el sonido; y la fuente de la BIOS en su dirección de la BIOS del MSX
(0x1D3F).

## La interrupción y los estados

INIT pone un `ret` en los ganchos H.KEYI y H.TIMI, borra la RAM, lee las teclas, prepara la partida y la pantalla y
pone un salto a 0x4042 en H.KEYI; después se queda en un `jr $`. La interrupción corta la del VDP mientras corre y,
en cada cuadro: los mandos, las cuentas de cuadros, los sprites de Simbad, la isla a la VRAM, el marcador, Simbad
(por su estado), los enemigos, la vista, el **estado general** y el sonido; al final vuelve a dar la interrupción
del VDP.

| estado general (0xEAB1) | |
|---|---|
| 0 | jugando |
| 1 | la presentación de CASIO (0x454D) |
| 2 | el título y la espera (0x471F) |
| 3 | se monta la isla (0x4B21) |
| 4 y 6 | el cartel ROUND / ISLAND (0x4A54) |
| 5 | GAME OVER (0x4AB6) |
| 7 y 8 | la vista se mueve una columna a la izquierda o a la derecha (0x5624, 0x562D) |

Simbad tiene 15 estados propios (0xEAD3, la tabla de 0x5680): en pie, alfanje, salto mortal, escalera, agachado,
cayendo, echado atrás, atrapado, muriendo, lanzado por el aire, quieto, y el pájaro que lo trae, que se lo lleva y
que viene a por él.

## Cómo se ha hecho

El trazado sigue el código desde INIT, la interrupción y las tablas de estados (el general, el de Simbad, el de los
enemigos, el del sonido, el de la palanca y los pasos de la pieza que se mueve), declaradas en
`src/sindbad.entries`. Lo demás se **midió en openMSX** (`tools/omsx_cobertura.tcl`) jugando y esperando a la
demostración en un Philips VG 8020: nada de lo que se ejecutó quedó fuera del trazado. Con el cartucho en la página
1 se mira el slot: antes de que entre el cartucho, en 0x4000-0x7FFF está el BASIC.

Las grabaciones de la web (`tools/guiones/*.tcl`, grabadas con `tools/lanza_graba.ps1` en C-BIOS) apuntan, en cada
cuadro, los registros del VDP, la RAM desde 0xE000, el PSG y la VRAM que ha cambiado. `tools/pantallas.py` ejecuta
el título con `tools/bios.py`, `tools/mapas.py` pinta las islas desde la RAM, `tools/gifs.py` hace los GIF y
`tools/musica.py` ejecuta el motor de sonido.

## La RAM

| | |
|---|---|
| 0xE000 | la fila 0 del teclado al encender (la tecla 0 en el bit 7: vidas sin fin; las 1-3: la isla) |
| 0xE001 | las marcas: la demostración, jugando, la isla abierta, la salida fuera, la salida tocada |
| 0xE002 / 0xE003 | la isla / la vuelta (BCD) |
| 0xE004-0xE008 | la palanca y los botones |
| 0xE009 / 0xE00B | la lista de la demostración / una orden de la demostración en marcha |
| 0xE00C-0xE017 | las cuentas de cuadros |
| 0xE018 | el número al azar |
| 0xE01A-0xE619 | la isla: 24 filas de 64 casillas, con los enemigos dibujados |
| 0xE69B-0xE69D | los puntos |
| 0xE69E-0xE6A0 | el récord |
| 0xE6B1 | lo desempaquetado |
| 0xEAB1-0xEAB3 | el estado general, el anterior y su paso |
| 0xEABB-0xEABE | los dos huecos |
| 0xEAD1 | la primera columna de la vista |
| 0xEAD3-0xEAD5 | el estado de Simbad, el anterior y su paso |
| 0xEAD7 | la fuerza |
| 0xEADC / 0xEADD / 0xEADE | la columna / la fila de Simbad / hacia dónde mira |
| 0xEAE3 | las vidas |
| 0xEAE5 | el dibujo de Simbad |
| 0xEB29 | los enemigos que faltan por derribar para abrir la isla |
| 0xEB32-0xEB61 | los ocho objetos, de 6 bytes |
| 0xEC09-0xEC0B | el tiro: direcciones, fila, columna |
| 0xEC0D-0xEC3A | el sonido: los efectos de los canales A y B y las dos voces de la música |
