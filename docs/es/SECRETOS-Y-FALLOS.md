# Secretos y fallos

Lo que se ha buscado en el código y lo que se ha encontrado. Un fallo solo entra aquí si está comprobado:
ejecutando la propia rutina del juego (`tools/bios.py`) o contra las grabaciones de openMSX.

## Secretos

- **Las teclas al encender**: la 0 da vidas sin fin, y la 1, la 2 y la 3 eligen la isla de salida, en binario.
  Comprobado en openMSX y contado en [Curiosidades](CURIOSIDADES.html). Es la única lectura de teclas sueltas de la
  ROM (`init`, 0x4026).
- **Los mandos**, en un solo sitio (`mandos`, 0x4113): la palanca del mando 1 o, si está quieta, los cursores; el
  botón 1 del mando o la barra; el botón 2 del mando o GRAPH (SNSMAT, fila 6). Primero el mando y luego el teclado,
  sin mezclarlos.

## Fallo: pasado el millón, los puntos y el récord a 400

Los puntos son tres bytes en BCD (0xE69B), seis cifras, y en pantalla salen las cinco de abajo con un 0 fijo detrás.
Cuando los puntos pasan del récord, `record_nuevo` (0x42DF) los copia al récord y **después** borra la cifra de arriba
de los dos, la que no se pinta (0x42EA-0x42F3). Mientras los puntos caben en cinco cifras no pasa nada; al pasar de
999.990 en pantalla, esa cifra es un 1 y al borrarla se van los puntos **y el récord**. Ejecutando aquí la suma de
puntos del juego:

| puntos (en pantalla) | récord | + | después: puntos | récord |
|---|---|---|---|---|
| 999.000 | 999.000 | 500 | 999.500 | 999.500 |
| 999.900 | 999.900 | 500 | **400** | **400** |
| 999.900 | 500.000 | 500 | **400** | **400** |
| 12.000 | 5.000 | 500 | 12.500 | 12.500 |

Quien pase del millón no solo ve volver el marcador a cero: pierde también el récord de la partida.

## Comprobado y correcto

- **Las vidas**: una más al acabar las siete islas, hasta siete (`isla_siguiente`, 0x584F).
- **La demostración** no suma puntos ni toca el récord (`puntos_suma`, 0x42B4, mira el bit 6 de 0xE001).
