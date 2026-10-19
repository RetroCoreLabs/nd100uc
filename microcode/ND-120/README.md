# ND-120 micro code source

Copies of the files of the same names in the NDMicroAsm repository, folder `src/NDMicroAsm/microcode/ND-120/`.

| File | What it is |
|---|---|
| `ND-120-DELILAH-L.uc`, `.SYMBOLS.TXT` | DELILAH micro code, version L. Assembled, it gives the same 4886 micro words as the 3202D factory ROM (4MB configuration) at the same addresses. The ROM holds 3306 more non-zero words that the source does not have. |

`tools/web-build/build-web.mjs` copies these into `web/MC/` and attaches them to the entry `nd120-3202D-4MB`: the label file gives the
disassembly its labels, and the page shows the source in its Source tab.
