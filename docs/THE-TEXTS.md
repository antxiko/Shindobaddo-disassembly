# The texts

The game writes with three sets of tiles. The name on the title, in kana and kanji, is drawn tiles of its own
(0x4801, unpacked to tiles 0x20-0x6D). The other title texts, the poster of each island and GAME OVER use the
**BIOS font**: the game copies the characters from "0" to "_" (0x1D3F) to tiles 0x80-0xAF of the two lower thirds
(`letras_bios`, 0x47E9), so a letter is its code + 0x50. The status line has its own eleven tiles: blank, the
colon and the letters S, C, H, I, R, D, P, O and W (0x429D).

| address | original | translation | where it appears |
|---|---|---|---|
| 0x49AD | シンドバッド | Sindbad | the title, first line, on the green box |
| 0x49E9 | ７つの冒険 | Seven adventures | the title, second line |
| 0x4A1D | © 1986 CASIO | © 1986 Casio | the title (the © is tile 0x6D, 0x4792) |
| 0x4A29 | HIGH SCORE | High score | the title, with the record |
| 0x4A35 | PUSH TRIGGER 1 | Press button 1 | the title |
| 0x4A45 | OR | or | the title |
| 0x4A49 | SPACE KEY | the space bar | the title |
| 0x4AA9 | ROUND | Round | the poster of each island, with its number |
| 0x4AAF | ISLAND | Island | the poster, with its number |
| 0x4B18 | GAME OVER | Game over | with no lives left |
| 0x429D | SC: | Score | the status line |
| 0x42A2 | RD: | Round | the status line |
| 0x42A5 | IS: | Island | the status line |
| 0x42AA | HI: | High score | the status line |
| 0x42B0 | POW: | Power | the status line, with its bar |

The two kana lines of the name are three rows of drawn tiles each, written by the list at 0x49AC (how far to move
on the screen, the tiles, 0) six times.
