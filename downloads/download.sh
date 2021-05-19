#!/bin/bash

wget "https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2-linux-x86_64.tar.gz"
wget "https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2-macos-universal.tar.gz"

wget "https://mirrors.kernel.org/gnu/gcc/gcc-11.1.0/gcc-11.1.0.tar.gz"
wget "https://www.mpfr.org/mpfr-current/mpfr-3.1.4.tar.bz2"
wget "https://gmplib.org/download/gmp/gmp-6.1.0.tar.lz"
wget "http://isl.gforge.inria.fr/isl-0.18.tar.bz2"
wget "https://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz"

wget "https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.1.tar.bz2"

wget "https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.bz2"
mv boost_1_76_0.tar.bz2 boost-1.76.0.tar.bz2

wget "https://github.com/xianyi/OpenBLAS/releases/download/v0.3.15/OpenBLAS-0.3.15.tar.gz"
mv OpenBLAS-0.3.15.tar.gz openblas-0.3.15.tar.gz

wget "https://github.com/flame/blis/archive/refs/tags/0.8.1.tar.gz"
mv 0.8.1.tar.gz blis-0.8.1.tar.gz

wget "https://github.com/llvm/llvm-project/archive/llvmorg-9.0.0.zip"


wget "https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/llvm-project-12.0.0.src.tar.xz"
mv llvm-project-12.0.0.src.tar.xz llvm-12.0.0.tar.xy
