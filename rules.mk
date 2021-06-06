
all : cmake gcc llvm hwloc ucx libevent openmpi boost openblas blis

clean :
	rm -rf log
	rm -rf build

cleanall : clean
	rm -rf opt
	rm -rf modulefiles

# -----------------------------------------------
# CMake
# -----------------------------------------------

cmake : cmake-3.20.2

cmake-3.20.2 : ${MODULE_DIR}/base/cmake/3.20.2.lua

${MODULE_DIR}/base/cmake/3.20.2.lua:
	${SRC_DIR}/build.sh cmake 3.20.2

# -----------------------------------------------
# GCC
# -----------------------------------------------

gcc : gcc-11.1.0

gcc-11.1.0 : ${MODULE_DIR}/base/gcc/11.1.0.lua

${MODULE_DIR}/base/gcc/11.1.0.lua:
	${SRC_DIR}/build.sh gcc 11.1.0

# -----------------------------------------------
# LLVM
# -----------------------------------------------

llvm : llvm-12.0.0

llvm-12.0.0 : ${MODULE_DIR}/base/llvm/12.0.0.lua

${MODULE_DIR}/base/llvm/12.0.0.lua:
	${SRC_DIR}/build.sh llvm 12.0.0

# -----------------------------------------------
# OpenMPI
# -----------------------------------------------

openmpi : openmpi-4.1.1-gcc-11.1.0 openmpi-4.1.1-llvm-12.0.0

openmpi-4.1.1-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/openmpi/4.1.1.lua

${MODULE_DIR}/compiler/gcc/11.1.0/openmpi/4.1.1.lua :
	${SRC_DIR}/build.sh openmpi 4.1.1 gcc 11.1.0

openmpi-4.1.1-llvm-12.0.0 : ${MODULE_DIR}/compiler/llvm/12.0.0/openmpi/4.1.1.lua

${MODULE_DIR}/compiler/llvm/12.0.0/openmpi/4.1.1.lua :
	${SRC_DIR}/build.sh openmpi 4.1.1 llvm 12.0.0

# -----------------------------------------------
# Boost
# -----------------------------------------------

boost : boost-1.76.0-gcc-11.1.0 boost-1.76.0-openmpi-4.1.1-gcc-11.1.0

boost-1.76.0-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/boost/1.76.0.lua

${MODULE_DIR}/compiler/gcc/11.1.0/boost/1.76.0.lua :
	${SRC_DIR}/build.sh boost 1.76.0 gcc 11.1.0

boost-1.76.0-openmpi-4.1.1-gcc-11.1.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/boost/1.76.0.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/boost/1.76.0.lua :
	${SRC_DIR}/build.sh boost 1.76.0 gcc 11.1.0 openmpi 4.1.1

# -----------------------------------------------
# OpenBLAS
# -----------------------------------------------

openblas : openblas-0.3.15-gcc-11.1.0

openblas-0.3.15-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/openblas/0.3.15.lua

${MODULE_DIR}/compiler/gcc/11.1.0/openblas/0.3.15.lua :
	${SRC_DIR}/build.sh openblas 0.3.15 gcc 11.1.0

# Something wonky here
# OpenBLAS uses gfortran with flang flags even when FC is specified
openblas-0.3.15-llvm-12.0.0 : ${MODULE_DIR}/compiler/llvm/12.0.0/openblas/0.3.15.lua

${MODULE_DIR}/compiler/llvm/12.0.0/openblas/0.3.15.lua :
	${SRC_DIR}/build.sh openblas 0.3.15 llvm 12.0.0

# -----------------------------------------------
# BLIS
# -----------------------------------------------

blis : blis-0.8.1-gcc-11.1.0 blis-0.8.1-llvm-12.0.0

blis-0.8.1-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/blis/0.8.1.lua

${MODULE_DIR}/compiler/gcc/11.1.0/blis/0.8.1.lua :
	${SRC_DIR}/build.sh blis 0.8.1 gcc 11.1.0

blis-0.8.1-llvm-12.0.0 : ${MODULE_DIR}/compiler/llvm/12.0.0/blis/0.8.1.lua

${MODULE_DIR}/compiler/llvm/12.0.0/blis/0.8.1.lua :
	${SRC_DIR}/build.sh blis 0.8.1 llvm 12.0.0

# -----------------------------------------------
# Intel OneAPI
# -----------------------------------------------

oneapi : oneapi-2021.2.0

oneapi-2021.2.0 : ${MODULE_DIR}/base/oneapi/2021.2.0.lua

${MODULE_DIR}/base/oneapi/2021.2.0.lua :
	${SRC_DIR}/build.sh oneapi 2021.2.0

# -----------------------------------------------
# VSCode 
# -----------------------------------------------

vscode : vscode-1.56.2

vscode-1.56.2 : ${MODULE_DIR}/base/vscode/1.56.2.lua

${MODULE_DIR}/base/vscode/1.56.2.lua :
	${SRC_DIR}/build.sh vscode 1.56.2

# -----------------------------------------------
# GPTL 
# -----------------------------------------------

gptl : gptl-8.0.3-gcc-11.1.0 gptl-8.0.3-openmpi-4.1.1-gcc-11.1.0

gptl-8.0.3-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/gptl/8.0.3.lua

${MODULE_DIR}/compiler/gcc/11.1.0/gptl/8.0.3.lua :
	${SRC_DIR}/build.sh gptl 8.0.3 gcc 11.1.0

gptl-8.0.3-openmpi-4.1.1-gcc-11.1.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/gptl/8.0.3.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/gptl/8.0.3.lua :
	${SRC_DIR}/build.sh gptl 8.0.3 gcc 11.1.0 openmpi 4.1.1

# Something not working here
gptl-8.0.3-openmpi-4.1.1-llvm-12.0.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/llvm/12.0.0/gptl/8.0.3.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/llvm/12.0.0/gptl/8.0.3.lua :
	${SRC_DIR}/build.sh gptl 8.0.3 llvm 12.0.0 openmpi 4.1.1

# -----------------------------------------------
# HWLOC 
# -----------------------------------------------

hwloc : hwloc-2.4.1-gcc-11.1.0 hwloc-2.4.1-llvm-12.0.0

hwloc-2.4.1-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/hwloc/2.4.1.lua

${MODULE_DIR}/compiler/gcc/11.1.0/hwloc/2.4.1.lua :
	${SRC_DIR}/build.sh hwloc 2.4.1 gcc 11.1.0

hwloc-2.4.1-llvm-12.0.0 : ${MODULE_DIR}/compiler/llvm/12.0.0/hwloc/2.4.1.lua

${MODULE_DIR}/compiler/llvm/12.0.0/hwloc/2.4.1.lua :
	${SRC_DIR}/build.sh hwloc 2.4.1 llvm 12.0.0

# -----------------------------------------------
# UCX
# -----------------------------------------------

ucx : ucx-1.10.1-gcc-11.1.0 ucx-1.10.1-llvm-12.0.0

ucx-1.10.1-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/ucx/1.10.1.lua

${MODULE_DIR}/compiler/gcc/11.1.0/ucx/1.10.1.lua :
	${SRC_DIR}/build.sh ucx 1.10.1 gcc 11.1.0

ucx-1.10.1-llvm-12.0.0 : ${MODULE_DIR}/compiler/llvm/12.0.0/ucx/1.10.1.lua

${MODULE_DIR}/compiler/llvm/12.0.0/ucx/1.10.1.lua :
	${SRC_DIR}/build.sh ucx 1.10.1 llvm 12.0.0

# -----------------------------------------------
# libevent
# -----------------------------------------------

libevent : libevent-2.1.12-gcc-11.1.0 libevent-2.1.12-llvm-12.0.0

libevent-2.1.12-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/libevent/2.1.12.lua

${MODULE_DIR}/compiler/gcc/11.1.0/libevent/2.1.12.lua :
	${SRC_DIR}/build.sh libevent 2.1.12 gcc 11.1.0

libevent-2.1.12-llvm-12.0.0 : ${MODULE_DIR}/compiler/llvm/12.0.0/libevent/2.1.12.lua

${MODULE_DIR}/compiler/llvm/12.0.0/libevent/2.1.12.lua :
	${SRC_DIR}/build.sh libevent 2.1.12 llvm 12.0.0
