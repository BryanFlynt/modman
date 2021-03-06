#!/bin/bash -l

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# Set the package name
export PKG=gcc
export PKG_VERSION=$1

# Support Library Versions (GCC 11.1)
#isl_version=0.18
#gmp_version=6.1.0
#mpfr_version=3.1.4
#mpc_version=1.0.3

# Support Library Versions (GCC 11.3)
mpfr_version=4.1.0
gmp_version=6.2.1
isl_version=0.24
mpc_version=1.2.1

# Load build environment
module purge

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# Make the build directory and cd into it
mkdir -p ${LIB_BUILD_DIR}
cd ${LIB_BUILD_DIR}

# Untar the tarball
tar --strip-components 1 -xzvf ${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.gz

# GCC also needs ISL
tar -xvf ${TAR_DIR}/isl-${isl_version}.tar.*
ln -s isl-${isl_version} isl

# GCC also needs GMP
tar -xvf ${TAR_DIR}/gmp-${gmp_version}.tar.*
ln -s gmp-${gmp_version} gmp

# GCC also needs MPFR
tar -xvf ${TAR_DIR}/mpfr-${mpfr_version}.tar.*
ln -s mpfr-${mpfr_version} mpfr

# GCC also needs MPC
tar -xvf ${TAR_DIR}/mpc-${mpc_version}.tar.*
ln -s mpc-${mpc_version} mpc

# Do an out of source build by making a temporary build directory
mkdir -p ${LIB_BUILD_DIR}/my_build
cd ${LIB_BUILD_DIR}/my_build

# Configure
${LIB_BUILD_DIR}/configure                           \
                --prefix=${LIB_INSTALL_DIR}          \
                --enable-languages=c,c++,fortran,lto \
                --enable-checking=release            \
                --enable-threads=posix               \
                --disable-multilib

# Build
make -j 8

# Install
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
prepend_path("MANPATH",         "${LIB_INSTALL_DIR}/share/man") 

-- Environment Variables
setenv("CPP", "${LIB_INSTALL_DIR}/bin/cpp")
setenv("CC",  "${LIB_INSTALL_DIR}/bin/gcc")
setenv("CXX", "${LIB_INSTALL_DIR}/bin/g++")
setenv("FC",  "${LIB_INSTALL_DIR}/bin/gfortran")
EOF
