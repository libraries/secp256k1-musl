ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
CC := clang-18
LD := ld.lld
CFLAGS := --target=riscv64 -march=rv64imc_zba_zbb_zbc_zbs -O3 -nostdinc -isystem $(ROOT_DIR)/deps/musl/release/include -fdata-sections -ffunction-sections
LDFLAGS := -nostdlib --sysroot $(ROOT_DIR)/deps/musl/release -L$(ROOT_DIR)/deps/musl/release/lib -L$(ROOT_DIR)/deps/compiler-rt-builtins-riscv/build -lc -lgcc -lcompiler-rt

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
	$(CC) $(CFLAGS) -Ideps/secp256k1/src -Ideps/secp256k1 -c -o build/secp256k1_bench.o c/secp256k1_bench.c
	$(LD) $(LDFLAGS) --gc-sections -o build/secp256k1_bench build/secp256k1_bench.o

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
	make CC=$(CC) LD=$(LD) OBJCOPY=llvm-objcopy AR=llvm-ar RANLIB=llvm-ranlib

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
