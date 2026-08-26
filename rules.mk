
.PHONY: clean cleanall

all : unpack_only compilers libraries mpi_compilers libraries_w_mpi

unpack_only : cmake

compilers : gcc oneapi

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

cmake : cmake-4.4.2

cmake-4.4.2 : ${MODMAN_MODULE_DIR}/base/cmake/4.4.2.lua

${MODMAN_MODULE_DIR}/base/cmake/4.4.2.lua:
	${MODMAN_SRC_DIR}/build.sh cmake 4.4.2

# -----------------------------------------------
# Paraview
# -----------------------------------------------

paraview : paraview-6.1.1

paraview-6.1.1 : ${MODMAN_MODULE_DIR}/base/paraview/6.1.1.lua

${MODMAN_MODULE_DIR}/base/paraview/6.1.1.lua:
	${MODMAN_SRC_DIR}/build.sh paraview 6.1.1

#
# **********************************************************
#                        Compilers
# **********************************************************
#

# -----------------------------------------------
# GCC
# -----------------------------------------------

gcc : gcc-16.2.0 gcc-16.2.0

gcc-16.2.0 : ${MODMAN_MODULE_DIR}/base/gcc/16.2.0.lua

${MODMAN_MODULE_DIR}/base/gcc/16.2.0.lua:
	${MODMAN_SRC_DIR}/build.sh gcc 16.2.0

gcc-15.3.0 : ${MODMAN_MODULE_DIR}/base/gcc/15.3.0.lua

${MODMAN_MODULE_DIR}/base/gcc/15.3.0.lua:
	${MODMAN_SRC_DIR}/build.sh gcc 15.3.0

# -----------------------------------------------
# Intel OneAPI
# -----------------------------------------------

oneapi : oneapi-2026.1.0

oneapi-2026.1.0 : ${MODMAN_MODULE_DIR}/base/oneapi/2026.1.0.lua

${MODMAN_MODULE_DIR}/base/oneapi/2026.1.0.lua :
	${MODMAN_SRC_DIR}/build.sh oneapi 2026.1.0

# -----------------------------------------------
# LLVM
# -----------------------------------------------

llvm : llvm-22.1.8

llvm-22.1.8 : ${MODMAN_MODULE_DIR}/base/llvm/22.1.8.lua

${MODMAN_MODULE_DIR}/base/llvm/22.1.8.lua:
	${MODMAN_SRC_DIR}/build.sh llvm 22.1.8

#
# **********************************************************
#         Tools & Libraries (Never Require MPI)
# **********************************************************
#

# -----------------------------------------------
# HWLOC 
# -----------------------------------------------

hwloc : hwloc-2.13.0-gcc-16.2.0 hwloc-2.13.0-gcc-15.3.0

hwloc-2.13.0-gcc-16.2.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/16.2.0/hwloc/2.13.0.lua

${MODMAN_MODULE_DIR}/compiler/gcc/16.2.0/hwloc/2.13.0.lua :
	${MODMAN_SRC_DIR}/build.sh hwloc 2.13.0 gcc 16.2.0

hwloc-2.13.0-gcc-15.3.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/15.3.0/hwloc/2.13.0.lua

${MODMAN_MODULE_DIR}/compiler/gcc/15.3.0/hwloc/2.13.0.lua :
	${MODMAN_SRC_DIR}/build.sh hwloc 2.13.0 gcc 15.3.0

# -----------------------------------------------
# UCX
# -----------------------------------------------

ucx : ucx-1.22.0-gcc-16.2.0 ucx-1.22.0-gcc-15.3.0

ucx-1.22.0-gcc-16.2.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/16.2.0/ucx/1.22.0.lua

${MODMAN_MODULE_DIR}/compiler/gcc/16.2.0/ucx/1.22.0.lua :
	${MODMAN_SRC_DIR}/build.sh ucx 1.22.0 gcc 16.2.0

ucx-1.22.0-gcc-15.3.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/15.3.0/ucx/1.22.0.lua

${MODMAN_MODULE_DIR}/compiler/gcc/15.3.0/ucx/1.22.0.lua :
	${MODMAN_SRC_DIR}/build.sh ucx 1.22.0 gcc 15.3.0

# -----------------------------------------------
# libevent
# -----------------------------------------------

libevent : libevent-2.1.13-gcc-16.2.0 libevent-2.1.13-gcc-15.3.0

libevent-2.1.13-gcc-16.2.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/16.2.0/libevent/2.1.13.lua

${MODMAN_MODULE_DIR}/compiler/gcc/16.2.0/libevent/2.1.13.lua :
	${MODMAN_SRC_DIR}/build.sh libevent 2.1.13 gcc 16.2.0

libevent-2.1.13-gcc-15.3.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/15.3.0/libevent/2.1.13.lua

${MODMAN_MODULE_DIR}/compiler/gcc/15.3.0/libevent/2.1.13.lua :
	${MODMAN_SRC_DIR}/build.sh libevent 2.1.13 gcc 15.3.0

# -----------------------------------------------
# Boost
# -----------------------------------------------

boost : boost-serial boost-mpi

boost-serial : boost-gcc

boost-gcc : boost-1.92.0-gcc-16.2.0 boost-1.92.0-gcc-15.3.0

boost-1.92.0-gcc-16.2.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/16.2.0/boost/1.92.0.lua

${MODMAN_MODULE_DIR}/compiler/gcc/16.2.0/boost/1.92.0.lua :
	${MODMAN_SRC_DIR}/build.sh boost 1.92.0 gcc 16.2.0

boost-1.92.0-gcc-15.3.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/15.3.0/boost/1.92.0.lua

${MODMAN_MODULE_DIR}/compiler/gcc/15.3.0/boost/1.92.0.lua :
	${MODMAN_SRC_DIR}/build.sh boost 1.92.0 gcc 15.3.0

# -----------------------------------------------
# Blis
# -----------------------------------------------

blis : blis-2.1.0-gcc-16.2.0 blis-2.1.0-gcc-15.3.0

blis-2.1.0-gcc-16.2.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/16.2.0/blis/2.1.0.lua

${MODMAN_MODULE_DIR}/compiler/gcc/16.2.0/blis/2.1.0.lua :
	${MODMAN_SRC_DIR}/build.sh blis 2.1.0 gcc 16.2.0

blis-2.1.0-gcc-15.3.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/15.3.0/blis/2.1.0.lua

${MODMAN_MODULE_DIR}/compiler/gcc/15.3.0/blis/2.1.0.lua :
	${MODMAN_SRC_DIR}/build.sh blis 2.1.0 gcc 15.3.0

#
# **********************************************************
#                 OpenMPI Compiler Wrappers
# **********************************************************
#

# -----------------------------------------------
# OpenMPI
# -----------------------------------------------

openmpi : openmpi-5.0.10-gcc-16.2.0 openmpi-5.0.10-gcc-15.3.0

openmpi-5.0.10-gcc-16.2.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/16.2.0/openmpi/5.0.10.lua

${MODMAN_MODULE_DIR}/compiler/gcc/16.2.0/openmpi/5.0.10.lua :
	${MODMAN_SRC_DIR}/build.sh openmpi 5.0.10 gcc 16.2.0

openmpi-5.0.10-gcc-15.3.0 : ${MODMAN_MODULE_DIR}/compiler/gcc/15.3.0/openmpi/5.0.10.lua

${MODMAN_MODULE_DIR}/compiler/gcc/15.3.0/openmpi/5.0.10.lua :
	${MODMAN_SRC_DIR}/build.sh openmpi 5.0.10 gcc 15.3.0

#
# **********************************************************
#                  Libraries (Require MPI)
# **********************************************************
#

# -----------------------------------------------
# Boost + MPI
# -----------------------------------------------

boost-mpi : boost-mpi-gcc

boost-mpi-gcc : boost-1.92.0-openmpi-5.0.10-gcc-16.2.0 boost-1.92.0-openmpi-5.0.10-gcc-15.3.0

boost-1.92.0-openmpi-5.0.10-gcc-16.2.0 : ${MODMAN_MODULE_DIR}/mpi/openmpi/5.0.10/gcc/16.2.0/boost/1.92.0.lua

${MODMAN_MODULE_DIR}/mpi/openmpi/5.0.10/gcc/16.2.0/boost/1.92.0.lua :
	${MODMAN_SRC_DIR}/build.sh boost 1.92.0 gcc 16.2.0 openmpi 5.0.10

boost-1.92.0-openmpi-5.0.10-gcc-15.3.0 : ${MODMAN_MODULE_DIR}/mpi/openmpi/5.0.10/gcc/15.3.0/boost/1.92.0.lua

${MODMAN_MODULE_DIR}/mpi/openmpi/5.0.10/gcc/15.3.0/boost/1.92.0.lua :
	${MODMAN_SRC_DIR}/build.sh boost 1.92.0 gcc 15.3.0 openmpi 5.0.10

# -----------------------------------------------
# HDF5
# -----------------------------------------------

hdf5 : hdf5-2.2.0-gcc-16.2.0 hdf5-2.2.0-gcc-15.3.0

hdf5-2.2.0-gcc-16.2.0 : ${MODMAN_MODULE_DIR}/gcc/16.2.0/hdf5/2.2.0.lua

${MODMAN_MODULE_DIR}/gcc/16.2.0/hdf5/2.2.0.lua :
	${MODMAN_SRC_DIR}/build.sh hdf5 2.2.0 gcc 16.2.0

hdf5-2.2.0-gcc-15.3.0 : ${MODMAN_MODULE_DIR}/gcc/15.3.0/hdf5/2.2.0.lua

${MODMAN_MODULE_DIR}/gcc/15.3.0/hdf5/2.2.0.lua :
	${MODMAN_SRC_DIR}/build.sh hdf5 2.2.0 gcc 15.3.0



