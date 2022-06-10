
.PHONY: clean cleanall

all : unpack_only compilers libraries

unpack_only : cmake

compilers : gcc llvm

libraries : isl gmp mpfr mpc

mpi_compilers : openmpi

libraries_w_mpi : boost gptl hdf5 netcdf

clean :
	rm -rf log
	rm -rf build

cleanall : clean
	rm -rf apps
	rm -rf modulefiles
	rm -rf downloads

#
# **********************************************************
#                   Unpack Packages (ONLY)
# **********************************************************
#

# -----------------------------------------------
# CMake
# -----------------------------------------------

cmake : cmake-3.20.2 cmake-3.23.2

cmake-3.20.2 : ${MODULE_DIR}/base/cmake/3.20.2.lua

${MODULE_DIR}/base/cmake/3.20.2.lua:
	${SRC_DIR}/build.sh cmake 3.20.2

cmake-3.23.2 : ${MODULE_DIR}/base/cmake/3.23.2.lua

${MODULE_DIR}/base/cmake/3.23.2.lua:
	${SRC_DIR}/build.sh cmake 3.23.2

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

${MODULE_DIR}/base/gcc/11.3.0.lua: isl-0.24 gmp-6.2.1 mpc-1.2.1 mpfr-4.1.0 
	${SRC_DIR}/build.sh gcc 11.3.0

# -----------------------------------------------
# LLVM
# -----------------------------------------------

llvm : llvm-14.0.0

llvm-14.0.0 : ${MODULE_DIR}/base/llvm/14.0.0.lua

${MODULE_DIR}/base/llvm/14.0.0.lua: cmake
	${SRC_DIR}/build.sh llvm 14.0.0

#
# **********************************************************
#         Tools & Libraries (Never Require MPI)
# **********************************************************
#

# -----------------------------------------------
# ISL 
# -----------------------------------------------

isl : isl-0.24

isl-0.24 :
	${SRC_DIR}/build.sh isl 0.24

# -----------------------------------------------
# GMP
# -----------------------------------------------

gmp : gmp-6.2.1

gmp-6.2.1 :
	${SRC_DIR}/build.sh gmp 6.2.1

# -----------------------------------------------
# MPC
# -----------------------------------------------

mpc : mpc-1.2.1

mpc-1.2.1 :
	${SRC_DIR}/build.sh mpc 1.2.1

# -----------------------------------------------
# MPFR
# -----------------------------------------------

mpfr : mpfr-4.1.0

mpfr-4.1.0 :
	${SRC_DIR}/build.sh mpfr 4.1.0
