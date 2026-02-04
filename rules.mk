
.PHONY: clean cleanall

all : unpack_only compilers libraries mpi_compilers libraries_w_mpi

unpack_only : cmake

compilers : gcc

libraries : hwloc ucx libevent blis

mpi_compilers : openmpi boost

libraries_w_mpi : hdf5

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

cmake : cmake-4.2.2

cmake-4.2.2 : ${MODMAN_MODULE_DIR}/base/cmake/4.2.2.lua

${MODMAN_MODULE_DIR}/base/cmake/4.2.2.lua:
	${MODMAN_SRC_DIR}/build.sh cmake 4.2.2

# -----------------------------------------------
# Paraview
# -----------------------------------------------

paraview : paraview-6.0.1

paraview-6.0.1 : ${MODMAN_MODULE_DIR}/base/paraview/6.0.1.lua

${MODMAN_MODULE_DIR}/base/paraview/6.0.1.lua:
	${MODMAN_SRC_DIR}/build.sh paraview 6.0.1

#
# **********************************************************
#                        Compilers
# **********************************************************
#

# -----------------------------------------------
# GCC
# -----------------------------------------------

gcc : gcc-15.2.0

gcc-15.2.0 : ${MODMAN_MODULE_DIR}/base/gcc/15.2.0.lua

${MODMAN_MODULE_DIR}/base/gcc/15.2.0.lua:
	${MODMAN_SRC_DIR}/build.sh gcc 15.2.0

# -----------------------------------------------
# LLVM
# -----------------------------------------------

llvm : llvm-21.1.8

llvm-21.1.8 : ${MODMAN_MODULE_DIR}/base/llvm/21.1.8.lua

${MODMAN_MODULE_DIR}/base/llvm/21.1.8.lua:
	${MODMAN_SRC_DIR}/build.sh llvm 21.1.8

#
# **********************************************************
#         Tools & Libraries (Never Require MPI)
# **********************************************************
#

# -----------------------------------------------
# HWLOC 
# -----------------------------------------------

hwloc : hwloc-2.12.2-gcc-15.2.0

hwloc-2.12.2-gcc-15.2.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/15.2.0/hwloc/2.12.2.lua

${MODMAN_MODULE_DIR}/compiler/gcc/15.2.0/hwloc/2.12.2.lua :
	${MODMAN_SRC_DIR}/build.sh hwloc 2.12.2 gcc 15.2.0

# -----------------------------------------------
# UCX
# -----------------------------------------------

ucx : ucx-1.20.0-gcc-15.2.0

ucx-1.20.0-gcc-15.2.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/15.2.0/ucx/1.20.0.lua

${MODMAN_MODULE_DIR}/compiler/gcc/15.2.0/ucx/1.20.0.lua :
	${MODMAN_SRC_DIR}/build.sh ucx 1.20.0 gcc 15.2.0

# -----------------------------------------------
# libevent
# -----------------------------------------------

libevent : libevent-2.1.12-gcc-15.2.0

libevent-2.1.12-gcc-15.2.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/15.2.0/libevent/2.1.12.lua

${MODMAN_MODULE_DIR}/compiler/gcc/15.2.0/libevent/2.1.12.lua :
	${MODMAN_SRC_DIR}/build.sh libevent 2.1.12 gcc 15.2.0

# -----------------------------------------------
# Boost
# -----------------------------------------------

boost : boost-serial boost-mpi

boost-serial : boost-gcc

boost-gcc : boost-1.90.0-gcc-15.2.0

boost-1.90.0-gcc-15.2.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/15.2.0/boost/1.90.0.lua

${MODMAN_MODULE_DIR}/compiler/gcc/15.2.0/boost/1.90.0.lua :
	${MODMAN_SRC_DIR}/build.sh boost 1.90.0 gcc 15.2.0

# -----------------------------------------------
# Blis
# -----------------------------------------------

blis : blis-2.0.0-gcc-15.2.0

blis-2.0.0-gcc-15.2.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/15.2.0/blis/2.0.0.lua

${MODMAN_MODULE_DIR}/compiler/gcc/15.2.0/blis/2.0.0.lua :
	${MODMAN_SRC_DIR}/build.sh blis 2.0.0 gcc 15.2.0

#
# **********************************************************
#                 OpenMPI Compiler Wrappers
# **********************************************************
#

# -----------------------------------------------
# OpenMPI
# -----------------------------------------------

openmpi : openmpi-5.0.9-gcc-15.2.0

openmpi-5.0.9-gcc-15.2.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/15.2.0/openmpi/5.0.9.lua

${MODMAN_MODULE_DIR}/compiler/gcc/15.2.0/openmpi/5.0.9.lua :
	${MODMAN_SRC_DIR}/build.sh openmpi 5.0.9 gcc 15.2.0

#
# **********************************************************
#                  Libraries (Require MPI)
# **********************************************************
#

# -----------------------------------------------
# Boost + MPI
# -----------------------------------------------

boost-mpi : boost-mpi-gcc

boost-mpi-gcc : boost-1.90.0-openmpi-5.0.9-gcc-15.2.0

boost-1.90.0-openmpi-5.0.9-gcc-15.2.0 : ${MODMAN_MODULE_DIR}/mpi/openmpi/5.0.9/gcc/15.2.0/boost/1.90.0.lua

${MODMAN_MODULE_DIR}/mpi/openmpi/5.0.9/gcc/15.2.0/boost/1.90.0.lua :
	${MODMAN_SRC_DIR}/build.sh boost 1.90.0 gcc 15.2.0 openmpi 5.0.9

# -----------------------------------------------
# HDF5
# -----------------------------------------------

hdf5 : hdf5-2.0.0-gcc-15.2.0

hdf5-2.0.0-gcc-15.2.0 : ${MODMAN_MODULE_DIR}/gcc/15.2.0/hdf5/2.0.0.lua

${MODMAN_MODULE_DIR}/gcc/15.2.0/hdf5/2.0.0.lua :
	${MODMAN_SRC_DIR}/build.sh hdf5 2.0.0 gcc 15.2.0
