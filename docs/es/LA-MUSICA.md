# La música

Cinco músicas, a dos voces. No son grabaciones hechas a mano: `tools/musica.py` **ejecuta el propio motor de
sonido de la ROM** con `tools/z80run.py` -la rutina del sonido (`sonido`, 0x7A73), cuadro a cuadro, con los números
que escribe el juego- y apunta lo que escribe en el PSG por la BIOS (WRTPSG; para el mezclador y para bajar el
volumen lee con RDPSG).

**Cotejadas con openMSX**: los registros de tono y volumen de los canales B y C casan con los grabados, **0
distintos** en todos los cuadros mirados. Se grabaron cinco veces (`tools/guiones/`): sin tocar nada, una partida
con un jugador al azar hasta GAME OVER, las siete islas, el final de una isla y la música de la isla abierta. Cada
cuadro grabado se empareja con el cuadro del motor que tiene la misma RAM en las dos voces; el motor arranca con la
RAM del sonido y el PSG como los tenía el juego. Mientras suena un efecto del canal B, el canal B no se mira.

La música de la isla abierta está **forzada** en su grabación: ningún guion derriba a todos los enemigos, así que
el guion escribe el número de la música donde lo escribe el juego (0x5C2A). Los efectos de sonido no están: el
alfanje, las caídas, el pájaro, el tiro y los demás.

## El motor

Va en la interrupción, una vez por cuadro. Primero los efectos del canal A (11, el número en 0xEC0D) y del canal B
(4, en 0xEC10); después las dos **voces**: cada una tiene un bloque de 11 bytes (0xEC25 y 0xEC30); el motor toca la
primera donde está, luego pasa la segunda a su sitio, la toca y devuelve las dos (0x7A8B). La primera toca en el
canal B las piezas de la lista de 0x7E99; la segunda, en el canal C, las de la lista de 0x7EC1. El juego no pide la
música: escribe el mismo número en las dos voces y el motor busca sus piezas (`voz`, 0x7D9F). Una pieza es una lista
de parejas (duración, nota); la nota 0 es un silencio y las demás, el tono de la tabla de 0x7E79 (16 notas, todas
teclas blancas, del do3 al la5). Cada nota empieza con el volumen de la voz y baja un paso cada 4 cuadros. Una lista
acaba con 0xFFFF: ninguna música vuelve a empezar.

| | Quién la pone | Dura |
|---|---|---:|
| el cartel | ROUND e ISLAND: el pájaro lleva a Simbad (0x56B3) | 4,3 s |
| la llegada | el pájaro deja a Simbad en la isla (0x56E7) | 2,1 s |
| la isla abierta | todos los enemigos que la abren derribados (0x5C28) | 0,5 s |
| la salida | el pájaro viene a por Simbad (0x577F, 0x57A2, 0x6192) | 5,0 s |
| GAME OVER | sin vidas (0x4ABE) | 2,1 s |

La música 2 es el golpe de la cuenta de la fuerza, uno por punto (0x5843): 8 cuadros, solo en la primera voz;
también se coteja, pero no tiene MP3.

## El cartel

<audio controls src="../audio/musica_cartel.mp3"></audio>

## La llegada

<audio controls src="../audio/musica_llegada.mp3"></audio>

## La isla abierta

<audio controls src="../audio/musica_isla_abierta.mp3"></audio>

## La salida

<audio controls src="../audio/musica_meta.mp3"></audio>

## GAME OVER

<audio controls src="../audio/musica_game_over.mp3"></audio>
