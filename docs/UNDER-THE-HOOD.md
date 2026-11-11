# Under the hood

## Rebuilding the ROM

`make verify` assembles `src/sindbad.asm` with pasmo and the 16 KB ROM comes out **byte for byte**. `make sanity`
checks what reassembly does not cover: that no byte declared as data is read as code, that no entry point falls
into data and that all 16,384 bytes are explained. `make test` runs the tests. The ROM is not in the repository:
put it in the root as `sindbad.rom` (the GoodMSX dump, `[!]`, sha1 `d120ca30...`).

| | bytes |
|---|---|
| traced code | 10,686 |
| named data | 5,698 |
| unexplained | 0 |

The listing has 2,218 comments on 5,443 instructions (40.7%), 639 routines and labels, none below 10% commented,
and no called routine without a name.

## The cartridge

16 KB in **page 1** (0x4000-0x7FFF), with INIT at 0x4010. What is not code: the tiles and colours of the title,
the islands, Sindbad, the bird and the enemies (packed with a bit mask for every eight bytes, `desempaqueta`,
0x43D0), the lists of pieces of each island, the classes of the enemies, the texts, the sound effects and the
music.

## The BIOS it uses

INIGRP for SCREEN 2, with its own table addresses written first in GRPNAM and the rest (0x40AE); WRTVDP for the VDP
registers; SETWRT and port 0x98 directly to write the VRAM (with a wait between bytes), and FILVRM, LDIRVM, LDIRMV
and WRTVRM; DISSCR and ENASCR; GTSTCK, GTTRIG and SNSMAT for the controls, KILBUF to empty the keyboard buffer;
WRTPSG, RDPSG and GICINI for the sound; and the BIOS font at its address in the MSX BIOS (0x1D3F).

## The interrupt and the states

INIT puts a `ret` on the H.KEYI and H.TIMI hooks, clears the RAM, reads the keys, sets up the game and the screen
and puts a jump to 0x4042 on H.KEYI; then it stays in a `jr $`. The interrupt switches the VDP interrupt off while
it runs and, every frame: the controls, the frame counts, Sindbad's sprites, the island to the VRAM, the status
line, Sindbad (by his state), the enemies, the view, the **general state** and the sound; at the end it switches the
VDP interrupt on again.

| general state (0xEAB1) | |
|---|---|
| 0 | playing |
| 1 | the CASIO intro (0x454D) |
| 2 | the title and the wait (0x471F) |
| 3 | the island is built (0x4B21) |
| 4 and 6 | the ROUND / ISLAND poster (0x4A54) |
| 5 | GAME OVER (0x4AB6) |
| 7 and 8 | the view moves one column to the left or to the right (0x5624, 0x562D) |

Sindbad has 15 states of his own (0xEAD3, the table at 0x5680): standing, scimitar, somersault, ladder, crouching,
falling, thrown back, stuck, dying, knocked up, still, and the bird bringing him, taking him away and coming for
him.

## How it was done

The trace follows the code from INIT, the interrupt and the state tables (the general state, Sindbad's, the
enemies', the sound's, the stick's and the steps of the moving piece), declared in `src/sindbad.entries`. The rest
was **measured in openMSX** (`tools/omsx_cobertura.tcl`) playing and waiting for the demo on a Philips VG 8020:
nothing that ran was left out of the trace. With the cartridge in page 1 the slot is checked: before the cartridge
comes in, 0x4000-0x7FFF holds BASIC.

The recordings for the site (`tools/guiones/*.tcl`, recorded with `tools/lanza_graba.ps1` on C-BIOS) log, on every
frame, the VDP registers, the RAM from 0xE000, the PSG and the VRAM that has changed. `tools/pantallas.py` runs the
title with `tools/bios.py`, `tools/mapas.py` paints the islands from the RAM, `tools/gifs.py` makes the GIFs and
`tools/musica.py` runs the sound engine.

## The RAM

| | |
|---|---|
| 0xE000 | keyboard row 0 at power-on (key 0 in bit 7: endless lives; keys 1-3: the island) |
| 0xE001 | the flags: the demo, playing, the island open, the way out out, the way out touched |
| 0xE002 / 0xE003 | the island / the round (BCD) |
| 0xE004-0xE008 | the stick and the buttons |
| 0xE009 / 0xE00B | the demo list / an order of the demo under way |
| 0xE00C-0xE017 | the frame counts |
| 0xE018 | the random number |
| 0xE01A-0xE619 | the island: 24 rows of 64 tiles, with the enemies drawn in |
| 0xE69B-0xE69D | the score |
| 0xE69E-0xE6A0 | the high score |
| 0xE6B1 | the unpacking buffer |
| 0xEAB1-0xEAB3 | the general state, the previous one and its step |
| 0xEABB-0xEABE | the two holes |
| 0xEAD1 | the first column of the view |
| 0xEAD3-0xEAD5 | Sindbad's state, the previous one and its step |
| 0xEAD7 | the power |
| 0xEADC / 0xEADD / 0xEADE | Sindbad's column / row / the side he faces |
| 0xEAE3 | the lives |
| 0xEAE5 | Sindbad's drawing |
| 0xEB29 | the enemies still to fell to open the island |
| 0xEB32-0xEB61 | the eight objects, 6 bytes each |
| 0xEC09-0xEC0B | the shot: directions, row, column |
| 0xEC0D-0xEC3A | the sound: the effects of channels A and B and the two music voices |
