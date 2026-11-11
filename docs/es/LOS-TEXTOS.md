# Los textos

El juego escribe con tres juegos de casillas. El nombre del título, en kana y kanji, son casillas dibujadas suyas
(0x4801, desempaquetadas en las casillas 0x20-0x6D). Los demás textos del título, el cartel de cada isla y GAME
OVER usan la **fuente de la BIOS**: el juego copia los caracteres del "0" al "_" (0x1D3F) a las casillas 0x80-0xAF
de los dos tercios de abajo (`letras_bios`, 0x47E9), así que una letra es su código + 0x50. El marcador tiene sus
once casillas propias: el blanco, los dos puntos y las letras S, C, H, I, R, D, P, O y W (0x429D).

| dirección | original | traducción | dónde sale |
|---|---|---|---|
| 0x49AD | シンドバッド | Simbad | el título, la primera línea, sobre el recuadro verde |
| 0x49E9 | ７つの冒険 | Siete aventuras | el título, la segunda línea |
| 0x4A1D | © 1986 CASIO | © 1986 Casio | el título (el © es la casilla 0x6D, 0x4792) |
| 0x4A29 | HIGH SCORE | Récord | el título, con el récord |
| 0x4A35 | PUSH TRIGGER 1 | Pulsa el botón 1 | el título |
| 0x4A45 | OR | o | el título |
| 0x4A49 | SPACE KEY | la barra | el título |
| 0x4AA9 | ROUND | Vuelta | el cartel de cada isla, con su número |
| 0x4AAF | ISLAND | Isla | el cartel, con su número |
| 0x4B18 | GAME OVER | Fin de la partida | sin vidas |
| 0x429D | SC: | Puntos | el marcador |
| 0x42A2 | RD: | Vuelta | el marcador |
| 0x42A5 | IS: | Isla | el marcador |
| 0x42AA | HI: | Récord | el marcador |
| 0x42B0 | POW: | Fuerza | el marcador, con su barra |

Las dos líneas del nombre son tres filas de casillas dibujadas cada una, escritas por la lista de 0x49AC (cuánto
avanzar en la pantalla, las casillas, 0) seis veces.
