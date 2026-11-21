#!/usr/bin/env bash
# Build script for AjralDEV Kernel c2q (Linux 4.19.113 + KernelSU Next + NetHunter)
#
# Requirements:
#   - GNU Make 4.3 (4.4 breaks Samsung techpack Makefiles)
#   - AOSP clang 10.0.6 (NDK) + aarch64-linux-android-4.9 GCC
#   - host packages: build-essential flex bison libssl-dev libelf-dev bc cpio lz4 dtc
#
# Layout expected:
#   ./c2q            kernel source tree (postkevone/c2q-kernelsu-next)
#   ./c2q/toolchain  gcc + llvm-arm-toolchain-ship
#   ./make43/bin     GNU Make 4.3 binary

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KERNEL="${KERNEL:-$ROOT/c2q}"
MAKE43="${MAKE43:-$ROOT/make43/bin/make}"

cd "$KERNEL"

export ARCH=arm64
export PATH="$KERNEL/toolchain/llvm-arm-toolchain-ship/10.0/bin:$KERNEL/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin:$PATH"

CROSS="$KERNEL/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
CC="$KERNEL/toolchain/llvm-arm-toolchain-ship/10.0/bin/clang"

# KernelSU Next (legacy branch) must already be set up:
#   curl -LSs https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh | bash -s legacy
# and the KSU core patches applied from kernelsu-patches/.

mkdir -p out

"$MAKE43" -j"$(nproc)" O=out \
  DTC_EXT="$KERNEL/tools/dtc" CONFIG_BUILD_ARM64_DT_OVERLAY=y \
  ARCH=arm64 CROSS_COMPILE="$CROSS" REAL_CC="$CC" CLANG_TRIPLE=aarch64-linux-gnu- \
  vendor/c2q_kor_singlew_defconfig

"$MAKE43" -j"$(nproc)" O=out \
  DTC_EXT="$KERNEL/tools/dtc" CONFIG_BUILD_ARM64_DT_OVERLAY=y \
  ARCH=arm64 CROSS_COMPILE="$CROSS" REAL_CC="$CC" CLANG_TRIPLE=aarch64-linux-gnu- \
  Image

echo
echo "Built: $KERNEL/out/arch/arm64/boot/Image"
ls -l "$KERNEL/out/arch/arm64/boot/Image"
sha256sum "$KERNEL/out/arch/arm64/boot/Image"
