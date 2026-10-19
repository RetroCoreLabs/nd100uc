#!/usr/bin/env node
/**
 * Build the web app at `web/` from source material in `external/meta/`.
 *
 * Produces:
 *   web/
 *   ├── index.html              (copied from src/index.html, to be refactored
 *   │                           in a later step to import the TS bundle)
 *   ├── Logo_ND.png
 *   ├── dist/nd100uc.mjs        (TS library bundled as browser ESM)
 *   ├── MC/
 *   │   ├── manifest.json        (catalogue of all available ROMs)
 *   │   ├── <entry>.CODE         (one per ROM / card / variant)
 *   │   ├── <entry>.SYMBOLS.TXT  (where symbols exist)
 *   │   └── <entry>.uc           (where source exists, for viewing)
 *
 * Run from the repo root:
 *   node tools/web-build/build-web.mjs
 */

import { readFileSync, writeFileSync, copyFileSync, mkdirSync, existsSync } from "node:fs";
import { dirname, resolve, basename } from "node:path";
import { fileURLToPath } from "node:url";
import { execSync } from "node:child_process";

const here = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(here, "..", "..");
const META = resolve(REPO, "external", "meta");
const WEB  = resolve(REPO, "web");
const MC   = resolve(WEB, "MC");

mkdirSync(MC, { recursive: true });
mkdirSync(resolve(WEB, "dist"), { recursive: true });

// --------------------------------------------------------------------
// 1. Combine ND-110 / ND-120 chip-pair ROMs into .CODE files using the
//    TS rom-combiner (via a tiny wrapper invocation).
// --------------------------------------------------------------------

async function combinePair(highPath, lowPath, outPath) {
  // Use the TS library directly by importing the built dist/.
  const { combineRoms, binaryToCodeBytes } =
    await import(resolve(REPO, "external", "meta", "lib", "ts", "dist", "index.js"));
  const high = new Uint8Array(readFileSync(highPath));
  const low  = new Uint8Array(readFileSync(lowPath));
  const mc = combineRoms(high, low);
  writeFileSync(outPath, binaryToCodeBytes(mc));
  console.log(`  combined -> ${basename(outPath)} (${mc.size} records)`);
}

// --------------------------------------------------------------------
// 2. Combine ND-100 multi-PROM card into per-role .CODE files using
//    the Python combiner (it's already in the meta repo).
// --------------------------------------------------------------------

function combineND100(variant, outPrefix) {
  const indir = resolve(META, "reference", "roms", "ND100", variant);
  if (!existsSync(indir)) {
    console.log(`  skip ND-100 ${variant} - folder missing`);
    return [];
  }
  const outdir = resolve(MC, "_nd100_tmp");
  mkdirSync(outdir, { recursive: true });
  execSync(
    `python3 ${resolve(META, "tools", "nd100-combine.py")} combine ` +
    `--variant ${variant} --indir ${indir} --outdir ${outdir}`,
    { stdio: "inherit" },
  );
  // Move files with the variant prefix into MC/ directly.
  const written = [];
  for (const role of ["microcode", "sequencer", "decode", "microcode_ext", "sequencer_ext"]) {
    const src = resolve(outdir, `${variant}-${role}.CODE`);
    if (!existsSync(src)) continue;
    const dst = resolve(MC, `${outPrefix}-${role}.CODE`);
    copyFileSync(src, dst);
    written.push(basename(dst));
    console.log(`  moved -> ${basename(dst)}`);
  }
  return written;
}

// --------------------------------------------------------------------
// 3. Pipeline
// --------------------------------------------------------------------

const manifestEntries = [];

function entry(obj) {
  manifestEntries.push(obj);
}

console.log("Copying pre-assembled .CODE files (patched K source)...");
{
  // This is our BEST disassembly target: a C#-compiled .CODE plus a
  // symbol file, so labels light up in the viewer.
  const raskCode = resolve(REPO, "microcode", "ND-110-RASK.CODE");
  const raskSyms = resolve(REPO, "microcode", "ND-110-RASK.SYMBOLS.TXT");
  const raskSrc  = resolve(META, "reference", "ND-110-RASK.uc");
  if (existsSync(raskCode)) copyFileSync(raskCode, resolve(MC, "ND-110-RASK.CODE"));
  if (existsSync(raskSyms)) copyFileSync(raskSyms, resolve(MC, "ND-110-RASK.SYMBOLS.TXT"));
  if (existsSync(raskSrc))  copyFileSync(raskSrc,  resolve(MC, "ND-110-RASK.uc"));
  const raskLst = resolve(REPO, "microcode", "ND-110-RASK.LISTING.TXT");
  if (existsSync(raskLst))  copyFileSync(raskLst,  resolve(MC, "ND-110-RASK.LISTING.TXT"));
  entry({
    id:          "nd110-rask-K-patched",
    name:        "ND-110 RASK - K version (patched source, with labels)",
    model:       "nd110",
    version:     "K (0o13)",
    storageForm: "token",
    codeFile:    "MC/ND-110-RASK.CODE",
    symbolsFile: "MC/ND-110-RASK.SYMBOLS.TXT",
    sourceFile:  "MC/ND-110-RASK.uc",
    listingFile: "MC/ND-110-RASK.LISTING.TXT",
    notes:       "C# assembler output from the user-maintained RASK.uc. Version K (0o13 at addr 0o20). 4865 instructions. Does NOT match the L-version factory ROMs we have; source needs upgrade to L before it can replace a factory ROM image.",
  });

  // DELILAH stub removed 2026-04-17: we now have real ND-120 microcode
  // via the nd120-3202D-4MB / 6MB entries below (Frode's reference set
  // confirmed the AM27256 chips are genuine ND-120 DELILAH).
}

console.log("\nCombining ND-110 3095 factory ROM (37948L + 37949L)...");
{
  const highP = resolve(META, "reference", "roms", "ND110", "37949L.bin");
  const lowP  = resolve(META, "reference", "roms", "ND110", "37948L.bin");
  if (existsSync(highP) && existsSync(lowP)) {
    const out = resolve(MC, "ND-110-3095-L.CODE");
    await combinePair(highP, lowP, out);
    entry({
      id: "nd110-3095-L",
      name: "ND-110 3095 card factory ROM (L version, 32-bit FP)",
      model: "nd110",
      version: "L (0o14)",
      storageForm: "token",
      codeFile: "MC/ND-110-3095-L.CODE",
      notes: "Combined from 37948L.bin (LOW) + 37949L.bin (HIGH). 8192 addresses. No symbols available. Per user: this is the ND-110 with the 32-bit floating-point microcode.",
    });
  }
}

console.log("\nCombining ND-120 3202D 4MB factory ROM (45132L + 45133L, 27C256)...");
{
  // These chips were previously mislabelled as "ND-110 AM27256 48-bit
  // FP" in the manifest. MD5 hashes confirmed bit-exact match with
  // Frode's independently-labelled "3202D ND120 32-bit 4MB" set
  // (2026-04-17), so they're ND-120 DELILAH microcode. The
  // storage-form discrepancy (canonical vs ND-110 token form) falls
  // out naturally: ND-120 doesn't XOR bits 22-27 the way ND-110 does.
  const highP = resolve(META, "reference", "roms", "ND120", "4MB", "45133L.27c256.b26.bin");
  const lowP  = resolve(META, "reference", "roms", "ND120", "4MB", "45132L.27c256.b23.bin");
  if (existsSync(highP) && existsSync(lowP)) {
    const out = resolve(MC, "ND-120-3202D-4MB.CODE");
    await combinePair(highP, lowP, out);
    entry({
      id: "nd120-3202D-4MB",
      name: "ND-120 3202D factory ROM (4MB config)",
      model: "nd120",
      storageForm: "canonical",
      codeFile: "MC/ND-120-3202D-4MB.CODE",
      notes: "Combined from 45132L.27c256.b23 (LOW) + 45133L.27c256.b26 (HIGH). ND-120 DELILAH microcode, 4MB-memory variant of the 3202D card. Canonical storage (no XOR on load). Previously mislabelled as ND-110 AM27256; identity confirmed by MD5 match with Frode's reference set.",
    });
  }
}

console.log("\nCombining ND-120 3202D 6MB factory ROM (45132L + 45133L, 27C256)...");
{
  // Second ND-120 variant, from Frode's "3202D ND120 32-bit 6MB" set.
  // ~2% of microwords differ vs 4MB (235 / 8192) - likely a later
  // revision with 6MB-memory support.
  const highP = resolve(META, "reference", "roms", "ND120", "6MB", "45133L.27c256.b26.bin");
  const lowP  = resolve(META, "reference", "roms", "ND120", "6MB", "45132L.27c256.b23.bin");
  if (existsSync(highP) && existsSync(lowP)) {
    const out = resolve(MC, "ND-120-3202D-6MB.CODE");
    await combinePair(highP, lowP, out);
    entry({
      id: "nd120-3202D-6MB",
      name: "ND-120 3202D factory ROM (6MB config)",
      model: "nd120",
      storageForm: "canonical",
      codeFile: "MC/ND-120-3202D-6MB.CODE",
      notes: "Combined from Frode's 6MB-variant 45132L/45133L 27C256 EPROMs. Differs from the 4MB variant in 235/8192 microwords (2.9%). Canonical storage (no XOR on load).",
    });
  }
}

// ND-100 microcode is decoded with the SAME engine as ND-110 (per user;
// deltas TBD). The sequencer (16-bit) and decode-PLA (12-bit) PROMs are
// NOT microinstructions, so they get marked `notMicroinstruction: true`
// and stay out of the disassembly selector -- they are a different
// kind of content, not a different decoder.
function nd100Entry(variant, outPrefix, name, role) {
  const isMicro = role === "microcode" || role === "microcode_ext";
  const roleBits = isMicro ? 64 : 12;
  const base = {
    id: `nd100-${variant}-${role}`,
    name: `ND-100 ${variant} - ${role}`,
    // Microcode banks are genuinely ND-100 - decoded by the ND-100
    // disassembler (lib/ts/src/disassembler-nd100.ts) which handles the
    // ND-100-specific bit layout (TC timing at 20-21, active-low
    // VECT0/SLWCS0/MAPJ0 at 25-27, 4-bit IDBS + SEXT at 37-41, role-
    // aware MIS at 42-43). The decode PLA is a separate ROM that maps
    // macro-opcodes to microaddress entry points - not a microinstruction.
    model: isMicro ? "nd100" : "nd100",
    // ND-100 3033S/3033E-CX factory PROMs store bits 22-27 INVERTED, the
    // same mask (0x0FC00000) as the ND-110. ND-06.018.01 "NORD-100
    // Microprogramming Description", Writing the Microprogram: "bits 22 - 27
    // are inverted after the word is assembled"; bits 22 to 27 are active
    // low. The CODE file written here is in PROM form (the chip words are not
    // changed); the web page flips it on load for model "ND-100"
    // (src/index.html). storageForm "prom" is not "token", so isND110 stays
    // false and the ND-110 flip is not applied a second time.
    // Compare: the ND-110 C# compiler also inverts bits 22-27 (ND-06.031.1
    // chapter 4, ND110Compile/Compiler.cs).
    storageForm: "prom",
    codeFile: `MC/${outPrefix}-${role}.CODE`,
    notes: isMicro
      ? `Combined 64-bit microword from 16 82S185 PROMs. PCB column inverse to bit position: d20 = bits 0-3 (low nibble), d5 = bits 60-63 (high nibble). Verified 100% bit-exact against Frode's independently-stitched reference images. Stored in PROM form: bits 22-27 are inverted (XOR 0x0FC00000 on load, ND-06.018.01).`
      : `Combined from 3 82S185 PROMs (b18-b20). 12-bit macro-opcode dispatch PLA: b20 = low nibble, b18 = high nibble. Not a microinstruction; cannot be disassembled as microcode.`,
  };
  if (!isMicro) base.notMicroinstruction = true;
  return base;
}

console.log("\nCombining ND-100 3033S base card (19 PROMs)...");
{
  const written = combineND100("3033S", "ND-100-3033S");
  for (const name of written) {
    const role = name.replace("ND-100-3033S-", "").replace(".CODE", "");
    entry(nd100Entry("3033S", "ND-100-3033S", name, role));
  }
}

console.log("\nCombining ND-100 3033E-CX extended card (35 PROMs)...");
{
  const written = combineND100("3033E-CX", "ND-100-3033E-CX");
  for (const name of written) {
    const role = name.replace("ND-100-3033E-CX-", "").replace(".CODE", "");
    entry(nd100Entry("3033E-CX", "ND-100-3033E-CX", name, role));
  }
}

// Clean up tmp dir
execSync(`rm -rf ${resolve(MC, "_nd100_tmp")}`, { stdio: "ignore" });

// --------------------------------------------------------------------
// 3b. Generate ND-100 SYMBOLS.TXT files from each decode-PLA ROM.
//     Labels combine: (a) manual-known entry points (CUST1-CUST10 at
//     WCS 0o4001-0o4013, STOP_RT at 0o3760, etc.), (b) PLA dispatch
//     targets named by their macro-opcode class, (c) a RESET label at
//     uaddr 0. Attach the generated symbols file to the corresponding
//     manifest entry so the web UI auto-loads it.
// --------------------------------------------------------------------

console.log("\nGenerating ND-100 symbol tables from decode PROMs...");
execSync(`node ${resolve(here, "generate-nd100-symbols.mjs")}`, {
  stdio: "inherit",
});

// Attach symbolsFile to each ND-100 microinstruction entry that has a
// generated .SYMBOLS.TXT next to it on disk.
for (const e of manifestEntries) {
  if (!e.id.startsWith("nd100-")) continue;
  if (e.notMicroinstruction) continue;
  const symbolsPath = e.codeFile.replace(/\.CODE$/, ".SYMBOLS.TXT");
  const symbolsAbs = resolve(WEB, symbolsPath);
  if (existsSync(symbolsAbs)) {
    e.symbolsFile = symbolsPath;
  }
}

// --------------------------------------------------------------------
// 3c. Labelled ND-100 sources (microcode/ND-100/, written back from the
//     printed Norsk Data listing, see microcode/ND-100/README.md). Their
//     assembled .CODE is bit-identical to the 3033S and 3033E-CX chip images,
//     so the real label names of the source replace the decode-PLA labels
//     (L<address>) for those entries. The 32-bit floating point variant has
//     no chip image: its own assembled .CODE is added as a separate entry.
// --------------------------------------------------------------------

console.log("\nAdding the labelled ND-100 sources...");
{
  const SRC = resolve(REPO, "microcode", "ND-100");
  const copyToMC = (from, to) => copyFileSync(resolve(SRC, from), resolve(MC, to));

  const sourceOf = {
    "nd100-3033S-microcode":        { uc: "ND-100-3033S.uc",        sym: "ND-100-3033S.SYMBOLS.TXT" },
    "nd100-3033E-CX-microcode":     { uc: "ND-100-3033E-CX.uc",     sym: "ND-100-3033E-CX.SYMBOLS.TXT" },
    "nd100-3033E-CX-microcode_ext": { uc: "ND-100-3033E-CX.uc",     sym: "ND-100-3033E-CX.SYMBOLS.TXT" },
  };
  for (const e of manifestEntries) {
    const s = sourceOf[e.id];
    if (!s || !existsSync(resolve(SRC, s.uc))) continue;
    copyToMC(s.uc, s.uc);
    copyToMC(s.sym, e.codeFile.replace(/^MC\//, "").replace(/\.CODE$/, ".SYMBOLS.TXT"));
    e.sourceFile = `MC/${s.uc}`;
    const lst = s.uc.replace(/\.uc$/, ".LISTING.TXT");
    if (existsSync(resolve(SRC, lst))) { copyToMC(lst, lst); e.listingFile = `MC/${lst}`; }
    e.symbolsFile = e.codeFile.replace(/\.CODE$/, ".SYMBOLS.TXT");
    e.notes += " Labels and source: the labelled .uc (assembles to this image bit for bit).";
  }

  // 32-bit floating point (PROM set 026XX). The page finds the decode PLA by
  // the file name (-microcode -> -decode); the 3033S decode PROMs are on the
  // same card and the entry points of the 32-bit routines are at the same
  // addresses as the 48-bit ones (checked in the README of microcode/ND-100).
  if (existsSync(resolve(SRC, "ND-100-3033S-32BIT-FLOAT.CODE"))) {
    copyToMC("ND-100-3033S-32BIT-FLOAT.CODE", "ND-100-3033S-32BIT-FLOAT-microcode.CODE");
    copyToMC("ND-100-3033S-32BIT-FLOAT.SYMBOLS.TXT", "ND-100-3033S-32BIT-FLOAT-microcode.SYMBOLS.TXT");
    copyToMC("ND-100-3033S-32BIT-FLOAT.uc", "ND-100-3033S-32BIT-FLOAT.uc");
    copyToMC("ND-100-3033S-32BIT-FLOAT.LISTING.TXT", "ND-100-3033S-32BIT-FLOAT.LISTING.TXT");
    if (existsSync(resolve(MC, "ND-100-3033S-decode.CODE"))) {
      copyFileSync(resolve(MC, "ND-100-3033S-decode.CODE"), resolve(MC, "ND-100-3033S-32BIT-FLOAT-decode.CODE"));
    }
    entry({
      id:          "nd100-3033S-32bit-float-microcode",
      name:        "ND-100 3033S 32-bit floating point (source, no chip image)",
      model:       "nd100",
      storageForm: "prom",
      codeFile:    "MC/ND-100-3033S-32BIT-FLOAT-microcode.CODE",
      symbolsFile: "MC/ND-100-3033S-32BIT-FLOAT-microcode.SYMBOLS.TXT",
      sourceFile:  "MC/ND-100-3033S-32BIT-FLOAT.uc",
      listingFile: "MC/ND-100-3033S-32BIT-FLOAT.LISTING.TXT",
      notes:       "3033S program with the words 0o517-0o1105 replaced by the printed 32-bit floating point listing (PROM set 026XX). Assembled from the labelled source; no chip dump exists for these PROMs, so these words are not proved against chips. Stored in PROM form (bits 22-27 inverted).",
    });
  }
}

// ND-120 DELILAH-L source: assembled, it gives the same micro words as the
// 3202D factory ROM (4MB configuration) at the same addresses (checked word for
// word: 4886 of 4886). The ROM holds 3306 more non-zero words that the source
// does not have.
{
  const SRC120 = resolve(REPO, "microcode", "ND-120");
  const e = manifestEntries.find((x) => x.id === "nd120-3202D-4MB");
  if (e && existsSync(resolve(SRC120, "ND-120-DELILAH-L.uc"))) {
    copyFileSync(resolve(SRC120, "ND-120-DELILAH-L.uc"), resolve(MC, "ND-120-DELILAH-L.uc"));
    copyFileSync(resolve(SRC120, "ND-120-DELILAH-L.SYMBOLS.TXT"), resolve(MC, "ND-120-3202D-4MB.SYMBOLS.TXT"));
    e.sourceFile = "MC/ND-120-DELILAH-L.uc";
    if (existsSync(resolve(SRC120, "ND-120-DELILAH-L.LISTING.TXT"))) {
      copyFileSync(resolve(SRC120, "ND-120-DELILAH-L.LISTING.TXT"), resolve(MC, "ND-120-DELILAH-L.LISTING.TXT"));
      e.listingFile = "MC/ND-120-DELILAH-L.LISTING.TXT";
    }
    e.symbolsFile = "MC/ND-120-3202D-4MB.SYMBOLS.TXT";
    e.notes += " Source and labels: DELILAH-L .uc, which assembles to 4886 of this ROM's words exactly (the ROM has 3306 more non-zero words that are not in the source).";
  }
}

// --------------------------------------------------------------------
// 4. Write manifest
// --------------------------------------------------------------------

// Legacy `files` array for the current in-page disassembler, which
// expects: { path (without .CODE extension), name, model, hasLabels, isND110 }.
// - storageForm: "token"     -> isND110: true  (needs XOR flip on load)
// - storageForm: "canonical" -> isND110: false (already canonical form)
// - storageForm: "prom"      -> isND110: false (ND-100: bits 22-27 inverted,
//                               flipped on load for model "ND-100" in index.html)
// Entries excluded:
//   - DELILAH stub (produces garbage)
//   - notMicroinstruction (ND-100 sequencer / decode PLA)
// Entries included: all real microinstruction ROMs, including the
// ND-100 microcode banks which are decoded with the ND-110 engine.
const legacyFiles = [];
for (const e of manifestEntries) {
  if (e.stub) continue;
  if (e.notMicroinstruction) continue;
  const pathNoExt = e.codeFile.replace(/\.CODE$/, "");
  legacyFiles.push({
    path: pathNoExt,
    name: e.name,
    // Display label: map internal model to human form. The ND-100
    // microcode entries have model=nd110 in the schema (decoded as
    // such) but we want the user to see "ND-100" in the selector.
    model: e.id.startsWith("nd100-") ? "ND-100"
         : e.model === "nd110" ? "ND-110"
         : e.model === "nd120" ? "ND-120"
         : "ND-100",
    hasLabels: !!e.symbolsFile,
    sourceFile: e.sourceFile,
    listingFile: e.listingFile,
    isND110: e.storageForm === "token",
  });
}

const defaultEntry = manifestEntries.find((e) => e.id === "nd110-rask-K-patched") ?? manifestEntries[0];
const defaultLegacyPath = defaultEntry
  ? defaultEntry.codeFile.replace(/\.CODE$/, "")
  : legacyFiles[0]?.path;

const manifest = {
  schemaVersion: 2,
  generatedAt: new Date().toISOString(),
  default: defaultEntry?.id,
  entries: manifestEntries,

  // Back-compat fields consumed by the current in-page disassembler
  // in src/index.html. These can be removed once the UI has been
  // migrated to consume `entries` directly.
  files: legacyFiles,
  defaultLegacy: defaultLegacyPath,
};
// The old UI reads `manifest.default` as the legacy path, not as an
// entry id. Keep both so both UIs work from the same file.
if (defaultLegacyPath) manifest.default = defaultLegacyPath;
writeFileSync(resolve(MC, "manifest.json"), JSON.stringify(manifest, null, 2));
console.log(
  `\nWrote ${manifestEntries.length} entries (+${legacyFiles.length} legacy files) to MC/manifest.json`,
);

// --------------------------------------------------------------------
// 5. Copy YAML definitions into web/defs/ so the browser can fetch
//    them for the disassembler. The canonical source lives in the
//    `nd-microcode-meta` submodule at external/meta/defs/.
// --------------------------------------------------------------------

const DEFS_SRC = resolve(META, "defs");
const DEFS_DST = resolve(WEB, "defs");
mkdirSync(resolve(DEFS_DST, "tokens"), { recursive: true });
mkdirSync(resolve(DEFS_DST, "fields"), { recursive: true });
for (const f of [
  "tokens/nd100-tokens.yaml",
  "tokens/nd110-tokens.yaml",
  "tokens/nd120-tokens.yaml",
  "fields/nd100-fields.yaml",
  "fields/nd110-fields.yaml",
  "fields/nd120-fields.yaml",
]) {
  const src = resolve(DEFS_SRC, f);
  if (existsSync(src)) copyFileSync(src, resolve(DEFS_DST, f));
}
console.log("Copied YAML definitions to web/defs/");

// --------------------------------------------------------------------
// 6. Bundle the TypeScript library as a browser-compatible ESM module.
//    esbuild resolves js-yaml from node_modules and emits a single
//    self-contained bundle at web/dist/nd100uc.mjs. We stub the
//    Node built-ins (fs/path/url) because the browser only uses
//    the text-based APIs (parseCodeBytes, parseSymbolsText,
//    parseTokensYaml, parseFieldsYaml, buildDefinitionPack, ...).
// --------------------------------------------------------------------

console.log("\nBundling TS library for the browser with esbuild...");
{
  // esbuild is a devDependency of lib/ts/, not of the repo root, so
  // import it directly from its install location.
  const esbuildPath = resolve(
    REPO, "external", "meta", "lib", "ts", "node_modules", "esbuild", "lib", "main.js",
  );
  const esbuild = await import(esbuildPath);
  const entry = resolve(REPO, "external", "meta", "lib", "ts", "dist", "index.js");
  const outfile = resolve(WEB, "dist", "nd100uc.mjs");

  // Stub plugin: replace Node built-ins with an empty module so any
  // accidental reference from the bundled file-based APIs doesn't pull
  // in `node:fs` at browser runtime. The browser surface never calls
  // those functions, so a no-op stub is sufficient.
  const nodeStub = {
    name: "node-builtins-stub",
    setup(build) {
      build.onResolve({ filter: /^node:(fs|path|url|child_process)$/ }, (args) => ({
        path: args.path,
        namespace: "node-stub",
      }));
      build.onLoad({ filter: /.*/, namespace: "node-stub" }, () => ({
        contents: [
          "export const readFileSync = () => { throw new Error('fs not available in browser'); };",
          "export const writeFileSync = () => { throw new Error('fs not available in browser'); };",
          "export const existsSync = () => false;",
          "export const dirname = (p) => p;",
          "export const join = (...parts) => parts.join('/');",
          "export const resolve = (...parts) => parts.join('/');",
          "export const basename = (p) => p.split('/').pop();",
          "export const fileURLToPath = (u) => u;",
          "export const execSync = () => { throw new Error('child_process not available in browser'); };",
        ].join("\n"),
        loader: "js",
      }));
    },
  };

  await esbuild.build({
    entryPoints: [entry],
    bundle: true,
    format: "esm",
    platform: "browser",
    target: ["es2022"],
    outfile,
    sourcemap: true,
    plugins: [nodeStub],
    logLevel: "info",
  });
  console.log(`  wrote ${outfile}`);
}

// --------------------------------------------------------------------
// 7. Copy static assets (HTML + logo) into web/
// --------------------------------------------------------------------

copyFileSync(resolve(REPO, "src", "index.html"), resolve(WEB, "index.html"));
copyFileSync(resolve(REPO, "src", "Logo_ND.png"), resolve(WEB, "Logo_ND.png"));
console.log("Copied index.html + Logo_ND.png");

console.log(`\nWeb build complete: ${WEB}`);
