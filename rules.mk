
.PHONY: clean cleanmem cleanall

all : unpack_only system_only compilers libraries mpi_compilers libraries_w_mpi

unpack_only : cmake paraview

system_only : ninja cgal

compilers : gcc llvm julia

libraries : cuda hwloc ucx libevent boost openblas blis occa

mpi_compilers : openmpi

libraries_w_mpi : boost-mpi #gptl hdf5 netcdf

clean :
	rm -rf log
	rm -rf build

cleanmem : clean
	rm -rf downloads

cleanall : cleanmem
	rm -rf apps
	rm -rf modulefiles

#
# **********************************************************
#                   Unpack Packages (ONLY)
# **********************************************************
#

# -----------------------------------------------
# CMake
# -----------------------------------------------

cmake : cmake-3.23.2 #cmake-3.20.2

cmake-3.20.2 : ${MODULE_DIR}/base/cmake/3.20.2.lua

${MODULE_DIR}/base/cmake/3.20.2.lua:
	${SRC_DIR}/build.sh cmake 3.20.2

cmake-3.23.2 : ${MODULE_DIR}/base/cmake/3.23.2.lua

${MODULE_DIR}/base/cmake/3.23.2.lua:
	${SRC_DIR}/build.sh cmake 3.23.2

# -----------------------------------------------
# Paraview
# -----------------------------------------------

paraview : paraview-5.10.1

paraview-5.10.1 : ${MODULE_DIR}/base/paraview/5.10.1.lua

${MODULE_DIR}/base/paraview/5.10.1.lua:
	${SRC_DIR}/build.sh paraview 5.10.1

#
# **********************************************************
#                   System Compiler (ONLY)
# **********************************************************
#

# -----------------------------------------------
# Ninja
# -----------------------------------------------

ninja : ninja-1.11.0

ninja-1.11.0 : cmake ${MODULE_DIR}/base/ninja/1.11.0.lua

${MODULE_DIR}/base/ninja/1.11.0.lua:
	${SRC_DIR}/build.sh ninja 1.11.0

# -----------------------------------------------
# CGAL
# -----------------------------------------------

cgal : cgal-5.4.1

cgal-5.4.1 : cmake ${MODULE_DIR}/base/cgal/5.4.1.lua

${MODULE_DIR}/base/cgal/5.4.1.lua:
	${SRC_DIR}/build.sh cgal 5.4.1

#
# **********************************************************
#                        Compilers
# **********************************************************
#

# -----------------------------------------------
# GCC
# -----------------------------------------------

gcc : gcc-11.3.0

gcc-11.3.0 : ${MODULE_DIR}/base/gcc/11.3.0.lua

${MODULE_DIR}/base/gcc/11.3.0.lua:
	${SRC_DIR}/build.sh isl 0.24
	${SRC_DIR}/build.sh gmp 6.2.1
	${SRC_DIR}/build.sh mpc 1.2.1
	${SRC_DIR}/build.sh mpfr 4.1.0 
	${SRC_DIR}/build.sh gcc 11.3.0

# -----------------------------------------------
# LLVM
# -----------------------------------------------

llvm : llvm-14.0.4 llvm-dev

llvm-6.0.0 : cmake ${MODULE_DIR}/base/llvm/6.0.0.lua

llvm-14.0.4 : cmake ${MODULE_DIR}/base/llvm/14.0.4.lua

llvm-dev : cmake ${MODULE_DIR}/base/llvm/dev.lua

${MODULE_DIR}/base/llvm/6.0.0.lua:
	${SRC_DIR}/build.sh llvm 6.0.0

${MODULE_DIR}/base/llvm/14.0.4.lua:
	${SRC_DIR}/build.sh llvm 14.0.4

${MODULE_DIR}/base/llvm/dev.lua:
	${SRC_DIR}/build.sh llvm dev

# -----------------------------------------------
# Julia
# -----------------------------------------------

julia : julia-1.8.1

julia-1.8.1 : ${MODULE_DIR}/base/julia/1.8.1.lua

${MODULE_DIR}/base/julia/1.8.1.lua:
	${SRC_DIR}/build.sh julia 1.8.1

#
# **********************************************************
#         Tools & Libraries (Never Require MPI)
# **********************************************************
#

# -----------------------------------------------
# CUDA
# -----------------------------------------------

cuda : cuda-11.7.1

cuda-11.7.1 : cmake ${MODULE_DIR}/base/cuda/11.7.1.lua

${MODULE_DIR}/base/cuda/11.7.1.lua:
	${SRC_DIR}/build.sh cuda 11.7.1

# -----------------------------------------------
# ISL (Download Only)
# -----------------------------------------------

isl : isl-0.24

isl-0.24 :
	${SRC_DIR}/build.sh isl 0.24

# -----------------------------------------------
# GMP (Download Only)
# -----------------------------------------------

gmp : gmp-6.2.1

gmp-6.2.1 :
	${SRC_DIR}/build.sh gmp 6.2.1

# -----------------------------------------------
# MPC (Download Only)
# -----------------------------------------------

mpc : mpc-1.2.1

mpc-1.2.1 :
	${SRC_DIR}/build.sh mpc 1.2.1

# -----------------------------------------------
# MPFR (Download Only)
# -----------------------------------------------

mpfr : mpfr-4.1.0

mpfr-4.1.0 :
	${SRC_DIR}/build.sh mpfr 4.1.0

# -----------------------------------------------
# Boost
# -----------------------------------------------

boost : boost-gcc boost-llvm

boost-gcc : boost-1.79.0-gcc-11.3.0

boost-llvm : boost-1.79.0-llvm-14.0.4

boost-1.79.0-gcc-11.3.0 : gcc-11.3.0 ${MODULE_DIR}/compiler/gcc/11.3.0/boost/1.79.0.lua

boost-1.79.0-llvm-14.0.4 : llvm-14.0.4 ${MODULE_DIR}/compiler/llvm/14.0.4/boost/1.79.0.lua

${MODULE_DIR}/compiler/gcc/11.3.0/boost/1.79.0.lua:
	${SRC_DIR}/build.sh boost 1.79.0 gcc 11.3.0

${MODULE_DIR}/compiler/llvm/14.0.4/boost/1.79.0.lua:
	${SRC_DIR}/build.sh boost 1.79.0 llvm 14.0.4

# -----------------------------------------------
# HWLOC 
# -----------------------------------------------

hwloc : hwloc-2.7.1-gcc hwloc-2.7.1-llvm

hwloc-2.7.1-gcc : hwloc-2.7.1-gcc-11.3.0

hwloc-2.7.1-llvm : hwloc-2.7.1-llvm-14.0.4

hwloc-2.7.1-gcc-11.3.0 : gcc-11.3.0 ${MODULE_DIR}/compiler/gcc/11.3.0/hwloc/2.7.1.lua

hwloc-2.7.1-llvm-14.0.4 : llvm-14.0.4 ${MODULE_DIR}/compiler/llvm/14.0.4/hwloc/2.7.1.lua

${MODULE_DIR}/compiler/gcc/11.3.0/hwloc/2.7.1.lua:
	${SRC_DIR}/build.sh hwloc 2.7.1 gcc 11.3.0

${MODULE_DIR}/compiler/llvm/14.0.4/hwloc/2.7.1.lua:
	${SRC_DIR}/build.sh hwloc 2.7.1 llvm 14.0.4

# -----------------------------------------------
# UCX
# -----------------------------------------------

ucx : ucx-1.12.1-gcc ucx-1.12.1-llvm

ucx-1.12.1-gcc : ucx-1.12.1-gcc-11.3.0

ucx-1.12.1-llvm : ucx-1.12.1-llvm-14.0.4

ucx-1.12.1-gcc-11.3.0 : gcc-11.3.0 ${MODULE_DIR}/compiler/gcc/11.3.0/ucx/1.12.1.lua

ucx-1.12.1-llvm-14.0.4 : llvm-14.0.4 ${MODULE_DIR}/compiler/llvm/14.0.4/ucx/1.12.1.lua

${MODULE_DIR}/compiler/gcc/11.3.0/ucx/1.12.1.lua:
	${SRC_DIR}/build.sh ucx 1.12.1 gcc 11.3.0

${MODULE_DIR}/compiler/llvm/14.0.4/ucx/1.12.1.lua:
	${SRC_DIR}/build.sh ucx 1.12.1 llvm 14.0.4

# -----------------------------------------------
# libevent
# -----------------------------------------------

libevent : libevent-2.1.12-gcc libevent-2.1.12-llvm

libevent-2.1.12-gcc : libevent-2.1.12-gcc-11.3.0

libevent-2.1.12-llvm : libevent-2.1.12-llvm-14.0.4

libevent-2.1.12-gcc-11.3.0 : gcc-11.3.0 ${MODULE_DIR}/compiler/gcc/11.3.0/libevent/2.1.12.lua

libevent-2.1.12-llvm-14.0.4 : llvm-14.0.4 ${MODULE_DIR}/compiler/llvm/14.0.4/libevent/2.1.12.lua

${MODULE_DIR}/compiler/gcc/11.3.0/libevent/2.1.12.lua:
	${SRC_DIR}/build.sh libevent 2.1.12 gcc 11.3.0

${MODULE_DIR}/compiler/llvm/14.0.4/libevent/2.1.12.lua:
	${SRC_DIR}/build.sh libevent 2.1.12 llvm 14.0.4

# -----------------------------------------------
# OpenBLAS
# -----------------------------------------------

openblas : openblas-0.3.20-gcc-11.3.0 #openblas-0.3.20-llvm-14.0.4

openblas-0.3.20-gcc-11.3.0 : gcc-11.3.0 ${MODULE_DIR}/compiler/gcc/11.3.0/openblas/0.3.20.lua

openblas-0.3.20-llvm-14.0.4 : llvm-14.0.4 ${MODULE_DIR}/compiler/llvm/14.0.4/openblas/0.3.20.lua

${MODULE_DIR}/compiler/gcc/11.3.0/openblas/0.3.20.lua:
	${SRC_DIR}/build.sh openblas 0.3.20 gcc 11.3.0

${MODULE_DIR}/compiler/llvm/14.0.4/openblas/0.3.20.lua:
	${SRC_DIR}/build.sh openblas 0.3.20 llvm 14.0.4

# -----------------------------------------------
# BLIS
# -----------------------------------------------

blis : blis-0.9.0-gcc-11.3.0 blis-0.9.0-llvm-14.0.4

blis-0.9.0-gcc-11.3.0 : gcc-11.3.0 ${MODULE_DIR}/compiler/gcc/11.3.0/blis/0.9.0.lua

blis-0.9.0-llvm-14.0.4 : llvm-14.0.4 ${MODULE_DIR}/compiler/llvm/14.0.4/blis/0.9.0.lua

${MODULE_DIR}/compiler/gcc/11.3.0/blis/0.9.0.lua:
	${SRC_DIR}/build.sh blis 0.9.0 gcc 11.3.0

${MODULE_DIR}/compiler/llvm/14.0.4/blis/0.9.0.lua:
	${SRC_DIR}/build.sh blis 0.9.0 llvm 14.0.4

# -----------------------------------------------
# OCCA
# -----------------------------------------------

occa : occa-1.4.0-gcc-11.3.0 #occa-1.4.0-llvm-14.0.4

occa-1.4.0-gcc-11.3.0 : cmake gcc-11.3.0 ${MODULE_DIR}/compiler/gcc/11.3.0/occa/1.4.0.lua

occa-1.4.0-llvm-14.0.4 : cmake llvm-14.0.4 ${MODULE_DIR}/compiler/llvm/14.0.4/occa/1.4.0.lua

${MODULE_DIR}/compiler/gcc/11.3.0/occa/1.4.0.lua:
	${SRC_DIR}/build.sh occa 1.4.0 gcc 11.3.0

${MODULE_DIR}/compiler/llvm/14.0.4/occa/1.4.0.lua:
	${SRC_DIR}/build.sh occa 1.4.0 llvm 14.0.4

#
# **********************************************************
#                 OpenMPI Compiler Wrappers
# **********************************************************
#

# -----------------------------------------------
# OpenMPI
# -----------------------------------------------

openmpi : openmpi-4.1.4-gcc openmpi-4.1.4-llvm

openmpi-4.1.4-gcc : openmpi-4.1.4-gcc-11.3.0

openmpi-4.1.4-llvm : openmpi-4.1.4-llvm-14.0.4

openmpi-4.1.4-gcc-11.3.0 : hwloc-2.7.1-gcc-11.3.0 ucx-1.12.1-gcc-11.3.0 libevent-2.1.12-gcc-11.3.0 ${MODULE_DIR}/compiler/gcc/11.3.0/openmpi/4.1.4.lua

openmpi-4.1.4-llvm-14.0.4 : hwloc-2.7.1-llvm-14.0.4 ucx-1.12.1-llvm-14.0.4 libevent-2.1.12-llvm-14.0.4 ${MODULE_DIR}/compiler/llvm/14.0.4/openmpi/4.1.4.lua

${MODULE_DIR}/compiler/gcc/11.3.0/openmpi/4.1.4.lua:
	${SRC_DIR}/build.sh openmpi 4.1.4 gcc 11.3.0

${MODULE_DIR}/compiler/llvm/14.0.4/openmpi/4.1.4.lua:
	${SRC_DIR}/build.sh openmpi 4.1.4 llvm 14.0.4

#
# **********************************************************
#                  Libraries (Require MPI)
# **********************************************************
#

# -----------------------------------------------
# Boost
# -----------------------------------------------

boost-mpi : boost-mpi-gcc boost-mpi-llvm

boost-mpi-gcc : boost-1.79.0-openmpi-4.1.4-gcc-11.3.0

boost-mpi-llvm : boost-1.79.0-openmpi-4.1.4-llvm-14.0.4

boost-1.79.0-openmpi-4.1.4-gcc-11.3.0 : openmpi-4.1.4-gcc-11.3.0 ${MODULE_DIR}/mpi/openmpi/4.1.4/gcc/11.3.0/boost/1.79.0.lua

boost-1.79.0-openmpi-4.1.4-llvm-14.0.4 : openmpi-4.1.4-llvm-14.0.4 ${MODULE_DIR}/mpi/openmpi/4.1.4/llvm/14.0.4/boost/1.79.0.lua

${MODULE_DIR}/mpi/openmpi/4.1.4/gcc/11.3.0/boost/1.79.0.lua:
	${SRC_DIR}/build.sh boost 1.79.0 gcc 11.3.0 openmpi 4.1.4

${MODULE_DIR}/mpi/openmpi/4.1.4/llvm/14.0.4/boost/1.79.0.lua:
	${SRC_DIR}/build.sh boost 1.79.0 llvm 14.0.4 openmpi 4.1.4
