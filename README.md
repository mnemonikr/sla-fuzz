# Overview

This fuzzer targets Ghidra's processing of `.sla` files.

Ghidra understands processor architectures through SLEIGH. Each processor is defined by a SLEIGH
`.slaspec` specification file. The SLEIGH compiler compiles this into a `.sla` file, which is used
to build the SLEIGH object in libsla.

# Usage

```sh
# One time setup
mkdir input
cargo run -p build-corpus

# Build sla-fuzz with ASAN to ensure ASAN libraries are linked
cargo +nightly rustc -p sla-fuzz -- -Z sanitizer=address

# Run the fuzzer
./target/debug/sla-fuzz input corpus
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
