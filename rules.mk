
.PHONY: clean cleanall

all : unpack_only compilers libraries mpi_compilers libraries_w_mpi

unpack_only : cmake # paraview gmsh vscode anaconda

compilers : gcc oneapi # llvm nvptx nvhpc sycl

libraries : hwloc ucx libevent # tbb openblas blis astyle

mpi_compilers : openmpi

libraries_w_mpi : boost gptl # hdf5 netcdf

clean :
	rm -rf log
	rm -rf build

cleanall : clean
	rm -rf opt
	rm -rf modulefiles

#
# **********************************************************
#                   Unpack Packages (ONLY)
# **********************************************************
#

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
# VSCode 
# -----------------------------------------------

vscode : vscode-1.56.2

vscode-1.56.2 : ${MODULE_DIR}/base/vscode/1.56.2.lua

${MODULE_DIR}/base/vscode/1.56.2.lua :
	${SRC_DIR}/build.sh vscode 1.56.2

# -----------------------------------------------
# Anaconda Python
# -----------------------------------------------

anaconda : anaconda-2021.5

anaconda-2021.5 : ${MODULE_DIR}/base/anaconda/2021.5.lua

${MODULE_DIR}/base/anaconda/2021.5.lua :
	${SRC_DIR}/build.sh anaconda 2021.5

#
# **********************************************************
#                        Compilers
# **********************************************************
#

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
# Intel OneAPI
# -----------------------------------------------

oneapi : oneapi-2021.3.0  # oneapi-2021.2.0

oneapi-2021.2.0 : ${MODULE_DIR}/base/oneapi/2021.2.0.lua

${MODULE_DIR}/base/oneapi/2021.2.0.lua :
	${SRC_DIR}/build.sh oneapi 2021.2.0

oneapi-2021.3.0 : ${MODULE_DIR}/base/oneapi/2021.3.0.lua

${MODULE_DIR}/base/oneapi/2021.3.0.lua :
	${SRC_DIR}/build.sh oneapi 2021.3.0

# -----------------------------------------------
# NVHPC + PGI Compiler
# -----------------------------------------------

nvhpc : nvhpc-21.5

nvhpc-21.5 : ${MODULE_DIR}/base/nvhpc/21.5.lua

${MODULE_DIR}/base/nvhpc/21.5.lua :
	${SRC_DIR}/build.sh nvhpc 21.5

# -----------------------------------------------
# NVPTX
# -----------------------------------------------

nvptx : nvptx-11.1.0

nvptx-11.1.0 : ${MODULE_DIR}/base/nvptx/11.1.0.lua

${MODULE_DIR}/base/nvptx/11.1.0.lua:
	${SRC_DIR}/build.sh nvptx 0.0.0 gcc 11.1.0

# -----------------------------------------------
# SYCL LLVM Compiler
# -----------------------------------------------

sycl : sycl-2021.8.16

sycl-2021.8.16 : ${MODULE_DIR}/base/sycl/2021.8.16.lua

${MODULE_DIR}/base/sycl/2021.8.16.lua :
	${SRC_DIR}/build.sh sycl 2021.8.16

# -----------------------------------------------
# CUDA
# -----------------------------------------------

cuda : cuda-11.3.1

cuda-11.3.1 : ${MODULE_DIR}/base/cuda/11.3.1.lua

${MODULE_DIR}/base/cuda/11.3.1.lua :
	${SRC_DIR}/build.sh cuda 11.3.1

#
# **********************************************************
#               Libraries (Never Require MPI)
# **********************************************************
#

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

ucx : ucx-1.12.1-gcc-11.1.0 ucx-1.12.1-llvm-12.0.0 ucx-1.12.1-nvptx-11.1.0

ucx-1.12.1-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/ucx/1.12.1.lua

${MODULE_DIR}/compiler/gcc/11.1.0/ucx/1.12.1.lua :
	${SRC_DIR}/build.sh ucx 1.12.1 gcc 11.1.0

ucx-1.12.1-llvm-12.0.0 : ${MODULE_DIR}/compiler/llvm/12.0.0/ucx/1.12.1.lua

${MODULE_DIR}/compiler/llvm/12.0.0/ucx/1.12.1.lua :
	${SRC_DIR}/build.sh ucx 1.12.1 llvm 12.0.0

ucx-1.12.1-nvptx-11.1.0 : ${MODULE_DIR}/compiler/nvptx/11.1.0/ucx/1.12.1.lua

${MODULE_DIR}/compiler/nvptx/11.1.0/ucx/1.12.1.lua :
	${SRC_DIR}/build.sh ucx 1.12.1 nvptx 11.1.0

ucx-1.12.1-pgi-21.5 : ${MODULE_DIR}/compiler/pgi/21.5/ucx/1.12.1.lua

${MODULE_DIR}/compiler/pgi/21.5/ucx/1.12.1.lua :
	${SRC_DIR}/build.sh ucx 1.12.1 pgi 21.5

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
# ASTYLE
# -----------------------------------------------

astyle : astyle-3.1.0

astyle-3.1.0 : ${MODULE_DIR}/base/astyle/3.1.0.lua

${MODULE_DIR}/base/astyle/3.1.0.lua :
	${SRC_DIR}/build.sh astyle 3.1.0 gcc 11.1.0

# -----------------------------------------------
# Intel TBB
# -----------------------------------------------

tbb : tbb-gcc tbb-oneapi

tbb-gcc : tbb-2021.3.0-gcc-11.1.0

tbb-oneapi : tbb-2021.3.0-oneapi-2021.3.0  # tbb-2021.3.0-oneapi-2021.2.0

tbb-2021.3.0-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/tbb/2021.3.0.lua

${MODULE_DIR}/compiler/gcc/11.1.0/tbb/2021.3.0.lua :
	${SRC_DIR}/build.sh tbb 2021.3.0 gcc 11.1.0

tbb-2021.3.0-oneapi-2021.2.0 : ${MODULE_DIR}/compiler/oneapi/2021.2.0/tbb/2021.3.0.lua

${MODULE_DIR}/compiler/oneapi/2021.2.0/tbb/2021.3.0.lua :
	${SRC_DIR}/build.sh tbb 2021.3.0 oneapi 2021.2.0

tbb-2021.3.0-oneapi-2021.3.0 : ${MODULE_DIR}/compiler/oneapi/2021.3.0/tbb/2021.3.0.lua

${MODULE_DIR}/compiler/oneapi/2021.3.0/tbb/2021.3.0.lua :
	${SRC_DIR}/build.sh tbb 2021.3.0 oneapi 2021.3.0

#
# **********************************************************
#                 OpenMPI Compiler Wrappers
# **********************************************************
#

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

#
# **********************************************************
#                  Libraries (Require MPI)
# **********************************************************
#

# -----------------------------------------------
# Boost
# -----------------------------------------------

boost : boost-gcc boost-oneapi # boost-nvptx

boost-gcc : boost-1.76.0-gcc-11.1.0 boost-1.76.0-openmpi-4.1.1-gcc-11.1.0 boost-1.77.0-gcc-11.1.0 boost-1.77.0-openmpi-4.1.1-gcc-11.1.0

boost-oneapi : boost-1.77.0-oneapi-2021.3.0 boost-1.77.0-impi-2021.3.0-oneapi-2021.3.0 # boost-1.76.0-oneapi-2021.3.0 boost-1.76.0-impi-2021.3.0-oneapi-2021.3.0

boost-nvptx : boost-1.76.0-nvptx-11.1.0 boost-1.76.0-openmpi-4.1.1-nvptx-11.1.0

boost-1.76.0-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/boost/1.76.0.lua

${MODULE_DIR}/compiler/gcc/11.1.0/boost/1.76.0.lua :
	${SRC_DIR}/build.sh boost 1.76.0 gcc 11.1.0

boost-1.76.0-openmpi-4.1.1-gcc-11.1.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/boost/1.76.0.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/boost/1.76.0.lua :
	${SRC_DIR}/build.sh boost 1.76.0 gcc 11.1.0 openmpi 4.1.1

boost-1.77.0-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/boost/1.77.0.lua

${MODULE_DIR}/compiler/gcc/11.1.0/boost/1.77.0.lua :
	${SRC_DIR}/build.sh boost 1.77.0 gcc 11.1.0

boost-1.77.0-openmpi-4.1.1-gcc-11.1.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/boost/1.77.0.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/boost/1.77.0.lua :
	${SRC_DIR}/build.sh boost 1.77.0 gcc 11.1.0 openmpi 4.1.1

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

boost-1.76.0-oneapi-2021.3.0 : ${MODULE_DIR}/compiler/oneapi/2021.3.0/boost/1.76.0.lua

${MODULE_DIR}/compiler/oneapi/2021.3.0/boost/1.76.0.lua :
	${SRC_DIR}/build.sh boost 1.76.0 oneapi 2021.3.0

boost-1.76.0-impi-2021.3.0-oneapi-2021.3.0 : ${MODULE_DIR}/mpi/impi/2021.3.0/oneapi/2021.3.0/boost/1.76.0.lua

${MODULE_DIR}/mpi/impi/2021.3.0/oneapi/2021.3.0/boost/1.76.0.lua :
	${SRC_DIR}/build.sh boost 1.76.0 oneapi 2021.3.0 impi 2021.3.0

boost-1.77.0-oneapi-2021.3.0 : ${MODULE_DIR}/compiler/oneapi/2021.3.0/boost/1.77.0.lua

${MODULE_DIR}/compiler/oneapi/2021.3.0/boost/1.77.0.lua :
	${SRC_DIR}/build.sh boost 1.77.0 oneapi 2021.3.0

boost-1.77.0-impi-2021.3.0-oneapi-2021.3.0 : ${MODULE_DIR}/mpi/impi/2021.3.0/oneapi/2021.3.0/boost/1.77.0.lua

${MODULE_DIR}/mpi/impi/2021.3.0/oneapi/2021.3.0/boost/1.77.0.lua :
	${SRC_DIR}/build.sh boost 1.77.0 oneapi 2021.3.0 impi 2021.3.0
	
boost-1.77.0-impi-2022.1.2-intel-2022.1.2 : ${MODULE_DIR}/mpi/impi/2022.1.2/intel/2022.1.2/boost/1.77.0.lua

${MODULE_DIR}/mpi/impi/2022.1.2/intel/2022.1.2/boost/1.77.0.lua :
	${SRC_DIR}/build.sh boost 1.77.0 intel 2022.1.2 impi 2022.1.2

# -----------------------------------------------
# GPTL 
# -----------------------------------------------

gptl : gptl-gcc gptl-oneapi # gptl-llvm

gptl-gcc : gptl-8.0.3-gcc-11.1.0 gptl-8.0.3-openmpi-4.1.1-gcc-11.1.0

gptl-oneapi : gptl-8.0.3-oneapi-2021.3.0 gptl-8.0.3-impi-2021.3.0-oneapi-2021.3.0

gptl-llvm : gptl-8.0.3-llvm-12.0.0  # Error within gptl

gptl-8.0.3-gcc-11.1.0 : ${MODULE_DIR}/compiler/gcc/11.1.0/gptl/8.0.3.lua

${MODULE_DIR}/compiler/gcc/11.1.0/gptl/8.0.3.lua :
	${SRC_DIR}/build.sh gptl 8.0.3 gcc 11.1.0

gptl-8.0.3-openmpi-4.1.1-gcc-11.1.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/gptl/8.0.3.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/gptl/8.0.3.lua :
	${SRC_DIR}/build.sh gptl 8.0.3 gcc 11.1.0 openmpi 4.1.1

gptl-8.0.3-llvm-12.0.0 : ${MODULE_DIR}/compiler/llvm/12.0.0/gptl/8.0.3.lua

${MODULE_DIR}/compiler/llvm/12.0.0/gptl/8.0.3.lua :
	${SRC_DIR}/build.sh gptl 8.0.3 llvm 12.0.0

gptl-8.0.3-openmpi-4.1.1-llvm-12.0.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/llvm/12.0.0/gptl/8.0.3.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/llvm/12.0.0/gptl/8.0.3.lua :
	${SRC_DIR}/build.sh gptl 8.0.3 llvm 12.0.0 openmpi 4.1.1

gptl-8.0.3-oneapi-2021.2.0 : ${MODULE_DIR}/compiler/oneapi/2021.2.0/gptl/8.0.3.lua

${MODULE_DIR}/compiler/oneapi/2021.2.0/gptl/8.0.3.lua :
	${SRC_DIR}/build.sh gptl 8.0.3 oneapi 2021.2.0

gptl-8.0.3-oneapi-2021.2.0 : ${MODULE_DIR}/mpi/impi/2021.2.0/compiler/oneapi/2021.2.0/gptl/8.0.3.lua

${MODULE_DIR}/mpi/impi/2021.2.0/compiler/oneapi/2021.2.0/gptl/8.0.3.lua :
	${SRC_DIR}/build.sh gptl 8.0.3 oneapi 2021.2.0 impi 2021.2.0

gptl-8.0.3-oneapi-2021.3.0 : ${MODULE_DIR}/compiler/oneapi/2021.3.0/gptl/8.0.3.lua

${MODULE_DIR}/compiler/oneapi/2021.3.0/gptl/8.0.3.lua :
	${SRC_DIR}/build.sh gptl 8.0.3 oneapi 2021.3.0

gptl-8.0.3-impi-2021.3.0-oneapi-2021.3.0 : ${MODULE_DIR}/mpi/impi/2021.3.0/compiler/oneapi/2021.3.0/gptl/8.0.3.lua

${MODULE_DIR}/mpi/impi/2021.3.0/compiler/oneapi/2021.3.0/gptl/8.0.3.lua :
	${SRC_DIR}/build.sh gptl 8.0.3 oneapi 2021.3.0 impi 2021.3.0

# -----------------------------------------------
# HDF5
# -----------------------------------------------

hdf5 : hdf5-1.12.1

hdf5-1.12.1 : hdf5-1.12.1-gcc-11.1.0 hdf5-1.12.1-openmpi-4.1.1-gcc-11.1.0

hdf5-1.12.1-gcc-11.1.0 : ${MODULE_DIR}/gcc/11.1.0/hdf5/1.12.1.lua

${MODULE_DIR}/gcc/11.1.0/hdf5/1.12.1.lua :
	${SRC_DIR}/build.sh hdf5 1.12.1 gcc 11.1.0

hdf5-1.12.1-llvm-12.0.0 : ${MODULE_DIR}/llvm/12.0.0/hdf5/1.12.1.lua

${MODULE_DIR}/llvm/12.0.0/hdf5/1.12.1.lua :
	${SRC_DIR}/build.sh hdf5 1.12.1 llvm 12.0.0

hdf5-1.12.1-openmpi-4.1.1-gcc-11.1.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/hdf5/1.12.1.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/hdf5/1.12.1.lua :
	${SRC_DIR}/build.sh hdf5 1.12.1 gcc 11.1.0 openmpi 4.1.1

hdf5-1.12.1-openmpi-4.1.1-llvm-12.0.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/llvm/12.0.0/hdf5/1.12.1.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/llvm/12.0.0/hdf5/1.12.1.lua :
	${SRC_DIR}/build.sh hdf5 1.12.1 llvm 12.0.0 openmpi 4.1.1

# -----------------------------------------------
# NetCDF C
# -----------------------------------------------

netcdf-c : netcdf-c-4.8.1

netcdf-c-4.8.1 : netcdf-c-4.8.1-gcc-11.1.0 netcdf-c-4.8.1-openmpi-4.1.1-gcc-11.1.0

netcdf-c-4.8.1-gcc-11.1.0 : ${MODULE_DIR}/gcc/11.1.0/netcdf-c/4.8.1.lua

${MODULE_DIR}/gcc/11.1.0/netcdf-c/4.8.1.lua :
	${SRC_DIR}/build.sh netcdf-c 4.8.1 gcc 11.1.0

netcdf-c-4.8.1-llvm-12.0.0 : ${MODULE_DIR}/llvm/12.0.0/netcdf-c/4.8.1.lua

${MODULE_DIR}/llvm/12.0.0/netcdf-c/4.8.1.lua :
	${SRC_DIR}/build.sh netcdf-c 4.8.1 llvm 12.0.0

netcdf-c-4.8.1-openmpi-4.1.1-gcc-11.1.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/netcdf-c/4.8.1.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/netcdf-c/4.8.1.lua :
	${SRC_DIR}/build.sh netcdf-c 4.8.1 gcc 11.1.0 openmpi 4.1.1

netcdf-c-4.8.1-openmpi-4.1.1-llvm-12.0.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/llvm/12.0.0/netcdf-c/4.8.1.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/llvm/12.0.0/netcdf-c/4.8.1.lua :
	${SRC_DIR}/build.sh netcdf-c 4.8.1 llvm 12.0.0 openmpi 4.1.1

# -----------------------------------------------
# NetCDF-CXX
# -----------------------------------------------

netcdf-cxx : netcdf-cxx-4.3.1

netcdf-cxx-4.3.1 : netcdf-cxx-4.3.1-gcc-11.1.0 netcdf-cxx-4.3.1-openmpi-4.1.1-gcc-11.1.0

netcdf-cxx-4.3.1-gcc-11.1.0 : ${MODULE_DIR}/gcc/11.1.0/netcdf-cxx/4.3.1.lua

${MODULE_DIR}/gcc/11.1.0/netcdf-cxx/4.3.1.lua :
	${SRC_DIR}/build.sh netcdf-cxx 4.3.1 gcc 11.1.0

netcdf-cxx-4.3.1-llvm-12.0.0 : ${MODULE_DIR}/llvm/12.0.0/netcdf-cxx/4.3.1.lua

${MODULE_DIR}/llvm/12.0.0/netcdf-cxx/4.3.1.lua :
	${SRC_DIR}/build.sh netcdf-cxx 4.3.1 llvm 12.0.0

netcdf-cxx-4.3.1-openmpi-4.1.1-gcc-11.1.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/netcdf-cxx/4.3.1.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/netcdf-cxx/4.3.1.lua :
	${SRC_DIR}/build.sh netcdf-cxx 4.3.1 gcc 11.1.0 openmpi 4.1.1

netcdf-cxx-4.3.1-openmpi-4.1.1-llvm-12.0.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/llvm/12.0.0/netcdf-cxx/4.3.1.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/llvm/12.0.0/netcdf-cxx/4.3.1.lua :
	${SRC_DIR}/build.sh netcdf-cxx 4.3.1 llvm 12.0.0 openmpi 4.1.1


# -----------------------------------------------
# NetCDF-Fortran
# -----------------------------------------------

netcdf-f : netcdf-f-4.5.3

netcdf-f-4.5.3 : netcdf-f-4.5.3-gcc-11.1.0 netcdf-f-4.5.3-openmpi-4.1.1-gcc-11.1.0

netcdf-f-4.5.3-gcc-11.1.0 : ${MODULE_DIR}/gcc/11.1.0/netcdf-f/4.5.3.lua

${MODULE_DIR}/gcc/11.1.0/netcdf-f/4.5.3.lua :
	${SRC_DIR}/build.sh netcdf-f 4.5.3 gcc 11.1.0

netcdf-f-4.5.3-llvm-12.0.0 : ${MODULE_DIR}/llvm/12.0.0/netcdf-f/4.5.3.lua

${MODULE_DIR}/llvm/12.0.0/netcdf-f/4.5.3.lua :
	${SRC_DIR}/build.sh netcdf-f 4.5.3 llvm 12.0.0

netcdf-f-4.5.3-openmpi-4.1.1-gcc-11.1.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/netcdf-f/4.5.3.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/gcc/11.1.0/netcdf-f/4.5.3.lua :
	${SRC_DIR}/build.sh netcdf-f 4.5.3 gcc 11.1.0 openmpi 4.1.1

netcdf-f-4.5.3-openmpi-4.1.1-llvm-12.0.0 : ${MODULE_DIR}/mpi/openmpi/4.1.1/llvm/12.0.0/netcdf-f/4.5.3.lua

${MODULE_DIR}/mpi/openmpi/4.1.1/llvm/12.0.0/netcdf-f/4.5.3.lua :
	${SRC_DIR}/build.sh netcdf-f 4.5.3 llvm 12.0.0 openmpi 4.1.1

# -----------------------------------------------
# NetCDF
# -----------------------------------------------

netcdf : netcdf-c netcdf-cxx netcdf-f
