# Shindobaddo Nanatsu no Bouken - commented disassembly

*(También [en castellano](README.es.md).)*

The commented disassembly of **Shindobaddo Nanatsu no Bouken** (シンドバッド７つの冒険, Casio, 1986) for the MSX: a 16 KB cartridge at 0x4000.

- **100%** of the binary explained: 10,686 bytes of code and 5,698 of named data, not one byte unassigned.
- **40.7%** of the listing commented, 639 routines and labels, none below 10% of comments.
- The listing reassembles into the original ROM **byte for byte**.
- The title comes from running the ROM, checked against openMSX; the seven islands, from the RAM the ROM builds; the scimitar, the somersault, the bird and the end of an island, played in GIF; the five tunes, from its own sound engine and identical to openMSX frame by frame.

The site: <https://antxiko.github.io/Shindobaddo-disassembly/>
(in Spanish: <https://antxiko.github.io/Shindobaddo-disassembly/es/>).

## Rebuilding it

The ROM image is not distributed. Put yours in the root as `sindbad.rom` (sha256 `ea8aeef3...`) and run `make`. The details, in [UNDER THE HOOD](docs/UNDER-THE-HOOD.md).

## Legal

The game belongs to Casio and its rights holders. The `LICENSE` covers only the tools, comments, analysis and documentation here. See [LEGAL-NOTICE.md](LEGAL-NOTICE.md).
