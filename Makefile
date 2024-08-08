ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
CC := clang-18
LD := clang-18
CFLAGS := --target=riscv64 -march=rv64imc_zba_zbb_zbc_zbs -O3 -nostdinc -isystem $(ROOT_DIR)/deps/musl/release/include -fdata-sections -ffunction-sections
LDFLAGS := -Wl,--static -Wl,--gc-sections -nostdlib --sysroot $(ROOT_DIR)/deps/musl/release -L$(ROOT_DIR)/deps/musl/release/lib -L$(ROOT_DIR)/deps/compiler-rt-builtins-riscv/build -lc -lgcc -lcompiler-rt

all: \
	deps \
	deps/compiler-rt-builtins-riscv \
	deps/compiler-rt-builtins-riscv/build/libcompiler-rt.a \
	deps/musl \
	deps/musl/release \
	deps/secp256k1 \
	deps/secp256k1/src/ecmult_static_pre_context.h \
	build \
	build/secp256k1_bench

build:
	mkdir build

build/secp256k1_bench:
	$(CC) $(CFLAGS) $(LDFLAGS) -Ideps/secp256k1/src -Ideps/secp256k1 -o build/secp256k1_bench c/secp256k1_bench.c

clean:
	rm -rf build
	rm -rf deps

deps:
	mkdir deps

deps/compiler-rt-builtins-riscv:
	cd deps && \
	git clone https://github.com/nervosnetwork/compiler-rt-builtins-riscv

deps/compiler-rt-builtins-riscv/build/libcompiler-rt.a:
	cd deps/compiler-rt-builtins-riscv && \
	make CC=$(CC) AR=llvm-ar

deps/musl:
	cd deps && \
	git clone https://github.com/xxuejie/musl && \
	cd musl && \
	git checkout 603d5e9

deps/musl/release:
	cd deps/musl && \
	CLANG=$(CC) ./ckb/build.sh

deps/secp256k1:
	cd deps && git clone https://github.com/nervosnetwork/secp256k1 --branch schnorr

deps/secp256k1/src/ecmult_static_pre_context.h:
	cd deps/secp256k1 && \
	./autogen.sh && \
	CC=$(CC) LD=$(LD) CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" ./configure --enable-ecmult-static-precomputation --with-ecmult-window=6 --enable-module-recovery --host=riscv64-elf && \
	make
