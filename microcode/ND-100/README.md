# ND-100 labelled micro code sources

Copies of the files of the same names in the NDMicroAsm repository, folder `src/NDMicroAsm/microcode/ND-100/`
(see the README there for how the text was written back from the printed 1985 Norsk Data listing and how it was checked).

| File | What it is |
|---|---|
| `ND-100-3033S.uc`, `.SYMBOLS.TXT` | 3033S card, PROM set 015XX. Assembles to the chip image bit for bit. |
| `ND-100-3033E-CX.uc`, `.SYMBOLS.TXT` | 3033E-CX card, base bank plus CX option bank. Assembles to the chip images bit for bit. |
| `ND-100-3033S-32BIT-FLOAT.uc`, `.SYMBOLS.TXT`, `.CODE` | 3033S program with the 32-bit floating point routines (PROM set 026XX). No chip image exists, so these words are not proved against chips. |

`tools/web-build/build-web.mjs` copies these into `web/MC/`. For the 3033S and 3033E-CX entries the label file replaces the
labels made from the decode PROMs (`L<address>`), and the page shows a Source link to the `.uc`. The 32-bit floating point
file is its own entry in the file list.
