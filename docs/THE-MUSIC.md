# The music

Five tunes, in two voices. They are not hand-made recordings: `tools/musica.py` **runs the ROM's own sound
engine** with `tools/z80run.py` -the sound routine (`sonido`, 0x7A73), frame by frame, with the numbers the game
writes- and logs what it writes to the PSG through the BIOS (WRTPSG; to set the mixer and to lower the volume it
reads with RDPSG).

**Checked against openMSX**: the tone and volume registers of channels B and C match the recorded ones, **0
different** in every frame checked. They were recorded five times (`tools/guiones/`): untouched, a game with a
random player until GAME OVER, the seven islands, the end of an island and the opening tune. Each recorded frame
is paired with the engine frame that has the same RAM in the two voices; the engine starts with the sound RAM and
the PSG as the game had them. While a channel B effect sounds, channel B is not checked.

The opening tune is **forced** in its recording: no script fells all the enemies, so the script writes the tune
number where the game writes it (0x5C2A). The sound effects are not here: the scimitar, the falls, the bird, the
shot and the rest.

## The engine

It runs in the interrupt, once per frame. First the effects of channel A (11, the number at 0xEC0D) and of
channel B (4, at 0xEC10); then the two **voices**: each has an 11-byte block (0xEC25 and 0xEC30); the engine plays the
first where it is, then moves the second into its place, plays it and moves both back (0x7A8B). The first plays on channel B the pieces of the list at 0x7E99; the second,
on channel C, those of the list at 0x7EC1. The game does not ask for the music: it writes the same number in both
voices and the engine looks for its pieces (`voz`, 0x7D9F). A piece is a list of (duration, note) pairs; note 0 is
a rest and the others, the tone from the table at 0x7E79 (16 notes, all white keys, from C3 to A5). Every note
starts at the voice's volume and loses one step every 4 frames. A list ends with 0xFFFF: no tune loops.

| | Who sets it | Length |
|---|---|---:|
| the poster | ROUND and ISLAND: the bird carries Sindbad (0x56B3) | 4.3 s |
| the arrival | the bird leaves Sindbad on the island (0x56E7) | 2.1 s |
| the island opens | all the enemies that open it are down (0x5C28) | 0.5 s |
| the way out | the bird comes for Sindbad (0x577F, 0x57A2, 0x6192) | 5.0 s |
| GAME OVER | no lives left (0x4ABE) | 2.1 s |

Tune 2 is the tick of the power count, one per point (0x5843): 8 frames on the first voice only; it is checked
too, but it has no MP3.

## The poster

<audio controls src="audio/musica_cartel.mp3"></audio>

## The arrival

<audio controls src="audio/musica_llegada.mp3"></audio>

## The island opens

<audio controls src="audio/musica_isla_abierta.mp3"></audio>

## The way out

<audio controls src="audio/musica_meta.mp3"></audio>

## GAME OVER

<audio controls src="audio/musica_game_over.mp3"></audio>
