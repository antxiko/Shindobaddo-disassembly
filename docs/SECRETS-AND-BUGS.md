# Secrets and bugs

What was searched for in the code and what was found. A bug only goes here if it has been checked: by running the
game's own routine (`tools/bios.py`) or against the openMSX recordings.

## Secrets

- **The keys at power-on**: 0 gives endless lives, and 1, 2 and 3 choose the starting island, in binary. Checked in
  openMSX and told in [Curiosities](CURIOSITIES.html). It is the only read of single keys in the ROM (`init`, 0x4026).
- **The controls**, in a single place (`mandos`, 0x4113): the stick of joystick 1 or, if it is still, the cursor
  keys; button 1 of the joystick or the space bar; button 2 of the joystick or GRAPH (SNSMAT, row 6). First the
  joystick and then the keyboard, without mixing them.

## Bug: past a million, the score and the high score down to 400

The score is three BCD bytes (0xE69B), six digits, and on screen the lower five are shown with a fixed 0 after them.
When the score goes past the high score, `record_nuevo` (0x42DF) copies it into the high score and **then** clears the
top digit of both, the one that is not drawn (0x42EA-0x42F3). While the score fits in five digits nothing happens; past
999,990 on screen that digit is a 1 and clearing it takes away the score **and the high score**. Running the game's
score addition here:

| score (on screen) | high score | + | after: score | high score |
|---|---|---|---|---|
| 999,000 | 999,000 | 500 | 999,500 | 999,500 |
| 999,900 | 999,900 | 500 | **400** | **400** |
| 999,900 | 500,000 | 500 | **400** | **400** |
| 12,000 | 5,000 | 500 | 12,500 | 12,500 |

Whoever goes past a million does not only see the scoreboard go back to zero: they lose the high score too.

## Checked and correct

- **The lives**: one more after the seven islands, up to seven (`isla_siguiente`, 0x584F).
- **The demo** adds no points and does not touch the high score (`puntos_suma`, 0x42B4, checks bit 6 of 0xE001).
