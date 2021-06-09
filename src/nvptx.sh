#!/bin/bash -l

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# Set the package name
export PKG=nvptx
export PKG_VERSION=$1
export COMPILER=$2
export COMPILER_VERSION=$3

# Support Library Versions
tools_version=${PKG_VERSION}
newlib_version=${PKG_VERSION}
isl_version=0.18
gmp_version=6.1.0
mpfr_version=3.1.4
mpc_version=1.0.3

NPROCS=12

# Load build environment
module purge
module load cuda

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${COMPILER_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${COMPILER_VERSION}

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# Make the build directory and cd into it
mkdir -p ${LIB_BUILD_DIR}
cd ${LIB_BUILD_DIR}

# UnPack and Link GCC with NVTPX NewLib
cd ${LIB_BUILD_DIR}
tar -xvf ${TAR_DIR}/${COMPILER}-${COMPILER_VERSION}.*

# UnPack NVTPX NewLib
cd ${LIB_BUILD_DIR}
tar xvf ${TAR_DIR}/nvptx-newlib-${tools_version}.*
ln -s ${LIB_BUILD_DIR}/nvptx-newlib/newlib ${COMPILER}-${COMPILER_VERSION}/newlib

# GCC also needs ISL
cd ${LIB_BUILD_DIR}
tar -xvf ${TAR_DIR}/isl-${isl_version}.tar.*
ln -s ${LIB_BUILD_DIR}/isl-${isl_version} ${COMPILER}-${COMPILER_VERSION}/isl

# GCC also needs GMP
cd ${LIB_BUILD_DIR}
tar -xvf ${TAR_DIR}/gmp-${gmp_version}.tar.*
ln -s ${LIB_BUILD_DIR}/gmp-${gmp_version} ${COMPILER}-${COMPILER_VERSION}/gmp

# GCC also needs MPFR
cd ${LIB_BUILD_DIR}
tar -xvf ${TAR_DIR}/mpfr-${mpfr_version}.tar.*
ln -s ${LIB_BUILD_DIR}/mpfr-${mpfr_version} ${COMPILER}-${COMPILER_VERSION}/mpfr

# GCC also needs MPC
cd ${LIB_BUILD_DIR}
tar -xvf ${TAR_DIR}/mpc-${mpc_version}.tar.*
ln -s ${LIB_BUILD_DIR}/mpc-${mpc_version} ${COMPILER}-${COMPILER_VERSION}/mpc

# Get the host target arch
cd ${LIB_BUILD_DIR}/${COMPILER}-${COMPILER_VERSION}
target=$(./config.guess)

# Build NVPTX Assembler, Linker and Tools
cd ${LIB_BUILD_DIR}
tar xvf ${TAR_DIR}/nvptx-tools-${tools_version}.*
cd nvptx-tools
./configure                                         \
    --with-cuda-driver-include=${CUDA_ROOT}/include \
    --with-cuda-driver-lib=${CUDA_ROOT}/lib64       \
    --prefix=${LIB_INSTALL_DIR}
make
make install

# Build Host GCC
cd ${LIB_BUILD_DIR}
mkdir nvptx_host
cd nvptx_host
../${COMPILER}-${COMPILER_VERSION}/configure                     \
       --target=nvptx-none                                       \
       --with-build-time-tools=${LIB_INSTALL_DIR}/nvptx-none/bin \
       --enable-as-accelerator-for=$target                       \
       --disable-sjlj-exceptions                                 \
       --enable-newlib-io-long-long                              \
       --enable-languages="c,c++,fortran,lto"                    \
       --prefix=${LIB_INSTALL_DIR}
make -j ${NPROCS}
make install

# Build Offload GCC
cd ${LIB_BUILD_DIR}
mkdir nvptx_target
cd nvptx_target
../${COMPILER}-${COMPILER_VERSION}/configure        \
    --enable-offload-targets=nvptx-none             \
    --with-cuda-driver-include=${CUDA_ROOT}/include \
    --with-cuda-driver-lib=${CUDA_ROOT}/lib64       \
    --disable-multilib                              \
    --enable-languages="c,c++,fortran,lto"          \
    --prefix=${LIB_INSTALL_DIR}
make -j ${NPROCS}
make install


# Create Module File
mkdir -p ${MODULE_DIR}/base/${PKG}
cat << EOF > ${MODULE_DIR}/base/${PKG}/${PKG_VERSION}.lua

help([[ ${PKG} version ${PKG_VERSION} ]])
family("compiler")

-- Conflicting modules
conflict("llvm")

-- Modulepath for packages built by this compiler
prepend_path("MODULEPATH", "${MODULE_DIR}/compiler/${PKG}/${PKG_VERSION}")

-- Environment Paths
prepend_path("PATH",            "${LIB_INSTALL_DIR}/bin")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib64")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib64")

-- Environment Variables
setenv("CPP", "${LIB_INSTALL_DIR}/bin/cpp")
setenv("CC",  "${LIB_INSTALL_DIR}/bin/gcc")
setenv("CXX", "${LIB_INSTALL_DIR}/bin/g++")
setenv("FC",  "${LIB_INSTALL_DIR}/bin/gfortran")
EOF
