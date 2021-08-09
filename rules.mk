
.PHONY: clean cleanall

all : cmake paraview gmsh gcc llvm nvptx nvhpc hwloc ucx libevent openmpi tbb boost openblas gptl blis anaconda

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
# Paraview
# -----------------------------------------------

paraview : paraview-5.9.1

paraview-5.9.1 : ${MODULE_DIR}/base/paraview/5.9.1.lua

${MODULE_DIR}/base/paraview/5.9.1.lua:
	${SRC_DIR}/build.sh paraview 5.9.1

# -----------------------------------------------
# GMSH
# -----------------------------------------------

gmsh : gmsh-4.8.4

gmsh-4.8.4 : ${MODULE_DIR}/base/gmsh/4.8.4.lua

${MODULE_DIR}/base/gmsh/4.8.4.lua:
	${SRC_DIR}/build.sh gmsh 4.8.4

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
# NVPTX
# -----------------------------------------------

nvptx : nvptx-11.1.0

nvptx-11.1.0 : ${MODULE_DIR}/base/nvptx/11.1.0.lua

${MODULE_DIR}/base/nvptx/11.1.0.lua:
	${SRC_DIR}/build.sh nvptx 0.0.0 gcc 11.1.0

# -----------------------------------------------
# OpenMPI
# -----------------------------------------------

openmpi : openmpi-4.1.1-gcc-11.1.0 openmpi-4.1.1-llvm-12.0.0 openmpi-4.1.1-nvptx-11.1.0

openmpi-4.1.1-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/openmpi/4.1.1.lua

${MODULE_DIR}/compiler/gcc/11.1.0/openmpi/4.1.1.lua :
	${SRC_DIR}/build.sh openmpi 4.1.1 gcc 11.1.0

openmpi-4.1.1-llvm-12.0.0 : ${MODULE_DIR}/compiler/llvm/12.0.0/openmpi/4.1.1.lua

${MODULE_DIR}/compiler/llvm/12.0.0/openmpi/4.1.1.lua :
	${SRC_DIR}/build.sh openmpi 4.1.1 llvm 12.0.0

openmpi-4.1.1-nvptx-11.1.0 : ${MODULE_DIR}/compiler/nvptx/11.1.0/openmpi/4.1.1.lua

${MODULE_DIR}/compiler/nvptx/11.1.0/openmpi/4.1.1.lua :
	${SRC_DIR}/build.sh openmpi 4.1.1 nvptx 11.1.0

openmpi-4.1.1-pgi-21.5 : ${MODULE_DIR}/compiler/pgi/21.5/openmpi/4.1.1.lua

${MODULE_DIR}/compiler/pgi/21.5/openmpi/4.1.1.lua :
	${SRC_DIR}/build.sh openmpi 4.1.1 pgi 21.5

# -----------------------------------------------
# Boost
# -----------------------------------------------

boost : boost-1.76.0-gcc-11.1.0 boost-1.76.0-openmpi-4.1.1-gcc-11.1.0 boost-1.76.0-nvptx-11.1.0 boost-1.76.0-openmpi-4.1.1-nvptx-11.1.0

boost-1.76.0-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/boost/1.76.0.lua

${MODULE_DIR}/compiler/gcc/11.1.0/boost/1.76.0.lua :
	${SRC_DIR}/build.sh boost 1.76.0 gcc 11.1.0

boost-1.76.0-openmpi-4.1.1-gcc-11.1.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/boost/1.76.0.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/boost/1.76.0.lua :
	${SRC_DIR}/build.sh boost 1.76.0 gcc 11.1.0 openmpi 4.1.1

boost-1.76.0-nvptx-11.1.0 : ${MODULE_DIR}/compiler/nvptx/11.1.0/boost/1.76.0.lua

${MODULE_DIR}/compiler/nvptx/11.1.0/boost/1.76.0.lua :
	${SRC_DIR}/build.sh boost 1.76.0 nvptx 11.1.0

boost-1.76.0-openmpi-4.1.1-nvptx-11.1.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/nvptx/11.1.0/boost/1.76.0.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/nvptx/11.1.0/boost/1.76.0.lua :
	${SRC_DIR}/build.sh boost 1.76.0 nvptx 11.1.0 openmpi 4.1.1

boost-1.76.0-pgi-21.5 : ${MODULE_DIR}/compiler/pgi/21.5/boost/1.76.0.lua

${MODULE_DIR}/compiler/pgi/21.5/boost/1.76.0.lua :
	${SRC_DIR}/build.sh boost 1.76.0 pgi 21.5

boost-1.76.0-openmpi-4.1.1-pgi-21.5 : ${MODULE_DIR}/mpi/openmpi/4.1.1/pgi/21.5/boost/1.76.0.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/pgi/21.5/boost/1.76.0.lua :
	${SRC_DIR}/build.sh boost 1.76.0 pgi 21.5 openmpi 4.1.1

# -----------------------------------------------
# OpenBLAS
# -----------------------------------------------

openblas : openblas-0.3.15-gcc-11.1.0 openblas-0.3.15-pgi-21.5

openblas-0.3.15-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/openblas/0.3.15.lua

${MODULE_DIR}/compiler/gcc/11.1.0/openblas/0.3.15.lua :
	${SRC_DIR}/build.sh openblas 0.3.15 gcc 11.1.0

# Something wonky here
# OpenBLAS uses gfortran with flang flags even when FC is specified
openblas-0.3.15-llvm-12.0.0 : ${MODULE_DIR}/compiler/llvm/12.0.0/openblas/0.3.15.lua

${MODULE_DIR}/compiler/llvm/12.0.0/openblas/0.3.15.lua :
	${SRC_DIR}/build.sh openblas 0.3.15 llvm 12.0.0

openblas-0.3.15-pgi-21.5 : ${MODULE_DIR}/compiler/pgi/21.5/openblas/0.3.15.lua

${MODULE_DIR}/compiler/pgi/21.5/openblas/0.3.15.lua :
	${SRC_DIR}/build.sh openblas 0.3.15 pgi 21.5

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

blis-0.8.1-pgi-21.5 : ${MODULE_DIR}/compiler/pgi/21.5/blis/0.8.1.lua

${MODULE_DIR}/compiler/pgi/21.5/blis/0.8.1.lua :
	${SRC_DIR}/build.sh blis 0.8.1 pgi 21.5

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

## LLVM will not build GPTL because of a configuration error
gptl-8.0.3-llvm-12.0.0 : ${MODULE_DIR}/compiler/llvm/12.0.0/gptl/8.0.3.lua

${MODULE_DIR}/compiler/llvm/12.0.0/gptl/8.0.3.lua :
	${SRC_DIR}/build.sh gptl 8.0.3 llvm 12.0.0

gptl-8.0.3-openmpi-4.1.1-llvm-12.0.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/llvm/12.0.0/gptl/8.0.3.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/llvm/12.0.0/gptl/8.0.3.lua :
	${SRC_DIR}/build.sh gptl 8.0.3 llvm 12.0.0 openmpi 4.1.1

# -----------------------------------------------
# HWLOC 
# -----------------------------------------------

hwloc : hwloc-2.4.1-gcc-11.1.0 hwloc-2.4.1-llvm-12.0.0 hwloc-2.4.1-nvptx-11.1.0

hwloc-2.4.1-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/hwloc/2.4.1.lua

${MODULE_DIR}/compiler/gcc/11.1.0/hwloc/2.4.1.lua :
	${SRC_DIR}/build.sh hwloc 2.4.1 gcc 11.1.0

hwloc-2.4.1-llvm-12.0.0 : ${MODULE_DIR}/compiler/llvm/12.0.0/hwloc/2.4.1.lua

${MODULE_DIR}/compiler/llvm/12.0.0/hwloc/2.4.1.lua :
	${SRC_DIR}/build.sh hwloc 2.4.1 llvm 12.0.0

hwloc-2.4.1-nvptx-11.1.0 : ${MODULE_DIR}/compiler/nvptx/11.1.0/hwloc/2.4.1.lua

${MODULE_DIR}/compiler/nvptx/11.1.0/hwloc/2.4.1.lua :
	${SRC_DIR}/build.sh hwloc 2.4.1 nvptx 11.1.0

hwloc-2.4.1-pgi-21.5 : ${MODULE_DIR}/compiler/pgi/21.5/hwloc/2.4.1.lua

${MODULE_DIR}/compiler/pgi/21.5/hwloc/2.4.1.lua :
	${SRC_DIR}/build.sh hwloc 2.4.1 pgi 21.5

# -----------------------------------------------
# UCX
# -----------------------------------------------

ucx : ucx-1.10.1-gcc-11.1.0 ucx-1.10.1-llvm-12.0.0 ucx-1.10.1-nvptx-11.1.0

ucx-1.10.1-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/ucx/1.10.1.lua

${MODULE_DIR}/compiler/gcc/11.1.0/ucx/1.10.1.lua :
	${SRC_DIR}/build.sh ucx 1.10.1 gcc 11.1.0

ucx-1.10.1-llvm-12.0.0 : ${MODULE_DIR}/compiler/llvm/12.0.0/ucx/1.10.1.lua

${MODULE_DIR}/compiler/llvm/12.0.0/ucx/1.10.1.lua :
	${SRC_DIR}/build.sh ucx 1.10.1 llvm 12.0.0

ucx-1.10.1-nvptx-11.1.0 : ${MODULE_DIR}/compiler/nvptx/11.1.0/ucx/1.10.1.lua

${MODULE_DIR}/compiler/nvptx/11.1.0/ucx/1.10.1.lua :
	${SRC_DIR}/build.sh ucx 1.10.1 nvptx 11.1.0

ucx-1.10.1-pgi-21.5 : ${MODULE_DIR}/compiler/pgi/21.5/ucx/1.10.1.lua

${MODULE_DIR}/compiler/pgi/21.5/ucx/1.10.1.lua :
	${SRC_DIR}/build.sh ucx 1.10.1 pgi 21.5

# -----------------------------------------------
# libevent
# -----------------------------------------------

libevent : libevent-2.1.12-gcc-11.1.0 libevent-2.1.12-llvm-12.0.0 libevent-2.1.12-nvptx-11.1.0

libevent-2.1.12-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/libevent/2.1.12.lua

${MODULE_DIR}/compiler/gcc/11.1.0/libevent/2.1.12.lua :
	${SRC_DIR}/build.sh libevent 2.1.12 gcc 11.1.0

libevent-2.1.12-llvm-12.0.0 : ${MODULE_DIR}/compiler/llvm/12.0.0/libevent/2.1.12.lua

${MODULE_DIR}/compiler/llvm/12.0.0/libevent/2.1.12.lua :
	${SRC_DIR}/build.sh libevent 2.1.12 llvm 12.0.0

libevent-2.1.12-nvptx-11.1.0 : ${MODULE_DIR}/compiler/nvptx/11.1.0/libevent/2.1.12.lua

${MODULE_DIR}/compiler/nvptx/11.1.0/libevent/2.1.12.lua :
	${SRC_DIR}/build.sh libevent 2.1.12 nvptx 11.1.0

libevent-2.1.12-pgi-21.5 : ${MODULE_DIR}/compiler/pgi/21.5/libevent/2.1.12.lua

${MODULE_DIR}/compiler/pgi/21.5/libevent/2.1.12.lua :
	${SRC_DIR}/build.sh libevent 2.1.12 pgi 21.5

# -----------------------------------------------
# CUDA
# -----------------------------------------------

cuda : cuda-11.3.1

cuda-11.3.1 : ${MODULE_DIR}/base/cuda/11.3.1.lua

${MODULE_DIR}/base/cuda/11.3.1.lua :
	${SRC_DIR}/build.sh cuda 11.3.1

# -----------------------------------------------
# NVHPC + PGI Compiler
# -----------------------------------------------

nvhpc : nvhpc-21.5

nvhpc-21.5 : ${MODULE_DIR}/base/nvhpc/21.5.lua

${MODULE_DIR}/base/nvhpc/21.5.lua :
	${SRC_DIR}/build.sh nvhpc 21.5

# -----------------------------------------------
# Anaconda Python
# -----------------------------------------------

anaconda : anaconda-2021.5

anaconda-2021.5 : ${MODULE_DIR}/base/anaconda/2021.5.lua

${MODULE_DIR}/base/anaconda/2021.5.lua :
	${SRC_DIR}/build.sh anaconda 2021.5

# -----------------------------------------------
# Intel TBB
# -----------------------------------------------

tbb : tbb-2021.3.0-gcc-11.1.0 tbb-2021.3.0-oneapi-2021.2.0

tbb-2021.3.0-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/tbb/2021.3.0.lua

${MODULE_DIR}/compiler/gcc/11.1.0/tbb/2021.3.0.lua :
	${SRC_DIR}/build.sh tbb 2021.3.0 gcc 11.1.0

tbb-2021.3.0-oneapi-2021.2.0 : ${MODULE_DIR}/compiler/oneapi/2021.2.0/tbb/2021.3.0.lua

${MODULE_DIR}/compiler/oneapi/2021.2.0/tbb/2021.3.0.lua :
	${SRC_DIR}/build.sh tbb 2021.3.0 oneapi 2021.2.0
