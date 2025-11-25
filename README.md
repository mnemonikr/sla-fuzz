# Overview

This fuzzer targets Ghidra's processing of `.sla` files.

Ghidra understands processor architectures through SLEIGH. Each processor is defined by a SLEIGH
`.slaspec` specification file. The SLEIGH compiler compiles this into a `.sla` file, which is used
to build the SLEIGH object in libsla.

Traditionally the `.sla` file has a fixed header followed by compressed data. This fuzzer is aware
of this structure and specifically targets the Ghidra uncompressed data parser. This improved the
fuzzing efficiency by 3x over an earlier version which used traditional structure aware methodology
to target the conventional libsla APIs.

# Usage

This fuzzer uses Address Sanitizer (ASAN) which requires Rust nightly compiler.

```sh
# One time setup to initialize the corpus directory
./build-corpus.rs

# Create input directory
mkdir input

# Build with ASAN and run fuzzer
RUSTFLAGS="-Zsanitizer=address" cargo +nightly run --target x86_64-unknown-linux-gnu --release -- input corpus
```

## Expected output

The libFuzzer output should appear when running

```
INFO: Running with entropic power schedule (0xFF, 100).
INFO: Seed: 28497745
INFO: Loaded 1 modules   (83891 inline 8-bit counters): 83891 [0x5a949bd3e530, 0x5a949bd52ce3),
INFO:        0 files found in input-freshness
INFO:      141 files found in corpus
```

# 🏆 Trophy Case

This fuzzer has found over 40 memory bugs. See [fuzzer findings](https://github.com/mnemonikr/sla-fuzz/issues?q=is%4Aissue%20label%3Afuzzer-finding) for full list of bugs.
