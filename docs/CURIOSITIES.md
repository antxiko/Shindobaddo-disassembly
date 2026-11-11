# Curiosities

## Keys at power-on: endless lives and the starting island

At start-up the game reads row 0 of the keyboard (keys 0 to 7), turns it round and stores it at 0xE000 (`init`,
0x4026): key 0 goes to bit 7 and keys 1 to 7 to bits 0 to 6. Two places read it:

- **Keys 1, 2 and 3 choose the starting island**, in binary, plus one (`partida_borra`, 0x4103): key 1 is island
  2, key 2 island 3, keys 1 and 2 island 4, key 3 island 5... and keys 2 and 3, island 7. All three would make 8,
  and then it is island 1.
- **Key 0 means endless lives**: before taking a life away, the game looks at bit 7 and, if it is set, does not
  take it (`vida_menos`, 0x5DAD). The shots do not hit him either (0x79B0), nor the touch checked at 0x6178.

**Checked in openMSX** (`tools/guiones/islas.tcl`): with keys 0, 2 and 3 held at power-on, 0xE000 is 0x86 and the
game starts on island 7; Sindbad dies several times in the recording and the five lives stay five. No text says so.

## The whole game in the interrupt

The main program is a `jr $` that jumps to itself forever (0x4040). Everything else runs in the interrupt (the
H.KEYI hook): the controls, Sindbad, the enemies, the screen, the state and the sound, every frame.

## Jumps into the middle of an instruction

To save a few bytes, some jumps land on the second byte of an instruction, which there is a different one:

| jump | lands at | there it is | what for |
|---|---|---|---|
| 0x4130, 0x4150 | 0x413C, 0x415C | `res 0,(hl)` / `res 1,(hl)` inside a `ld bc` | the button released |
| 0x417F | 0x41A2 | `ld a,7` inside a `ld hl` | the demo walks left |
| 0x5F33, 0x5F44 | 0x5F50 | `ld a,0x0D` inside a `ld hl` | the fall kills him |
| 0x6108 | 0x6119 | `ld a,3` inside a `ld bc` | how far an enemy throws him back |
| 0x612B, 0x612F | 0x6134, 0x6137 | `ld (hl),5` / `ld (hl),0x0C` inside two `ld hl` | the row he is thrown to |

## The demo walks by places, not by time

The demo does not keep a list of frames: each entry of its list (0x41CB) is a column. Sindbad walks towards it and,
when he gets there, does what the second byte says (the stick and the button), until the somersault or the ladder ends
(0xE00B).

## Clearing with the stack

Three rows of the island's RAM are cleared on every frame with the **stack**: the routine saves SP, points it at
the end of the rows and does 16 `push de` with two blanks, six times (`pantalla_ram_borra`, 0x44EA).

## The bird at the left edge

The giant bird is made of sprites, and sprites cannot stick out on the left of the screen. When it is within 8
columns of the edge, the game adds 32 to its X and sets bit 7 of the colour (the EC bit, which moves the sprite 32
dots to the left), and so it comes in little by little (`pajaro_dibuja`, 0x58EF).

## The BIOS font at a fixed address

The game copies the letters from address 0x1D3F of the BIOS (`letras_bios`, 0x47E9): the "0" of the font, if it
starts at 0x1BBF as in the MSX BIOS. It does not ask where the font is (CGTABL, 0x0004).

## Code nobody calls

Between two tables there are 23 bytes of code (0x6D68) that no jump and no pointer in the ROM reaches, and that did
not run in any recording: they copy 3 or 2 rows of two tiles, like the routine that copies 3 x 3 (0x4F67). There
are also six bytes (0x6BBB) that nothing points to.
