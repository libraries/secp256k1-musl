# Secp256k1 musl

Build [secp256k1](https://github.com/nervosnetwork/secp256k1) with clang-18 and musl.

## Build

```sh
$ make build

$ ll -h build/secp256k1_bench
# -rwxrwxr-x 1 ubuntu ubuntu 66K Aug  7 09:06 build/secp256k1_bench*

$ ckb-debugger --bin build/secp256k1_bench secp256k1_bench 033f8cf9c4d51a33206a6c1c6b27d2cc5129daa19dbd1fc148d395284f6b26411f 304402203679d909f43f073c7c1dcf8468a485090589079ee834e6eed92fea9b09b06a2402201e46f1075afa18f306715e7db87493e7b7e779569aa13c64ab3d09980b3560a3 foo bar
# Run result: 0
# Total cycles consumed: 1087688(1.0M)
```

## Comparison

|         Toolbox         | Size | Cycles |
| ----------------------- | ---- | ------ |
| riscv64-unknown-elf-gcc | 49K  | 1.2M   |
| clang-18 + musl         | 66K  | 1.0M   |
