#!/bin/bash -l
#
# ##################################################################################
#
# Script is always called as:
# > <package>.sh <package_version> <compiler> <compiler_version> <mpi> <mpi_version>
#
# ##################################################################################
#
#

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# Set the package name
export PKG=gcc
export PKG_VERSION=$1
export COMPILER=$3
export COMPILER_VERSION=$4
export MPI=$5
export MPI_VERSION=$6

#
# GCC can be built with a series of other libraries available
#
if [[ "${PKG_VERSION}" == "11.1.0" ]]; then
    isl_version=0.18
    gmp_version=6.1.0
    mpfr_version=3.1.4
    mpc_version=1.0.3
elif [[ "${PKG_VERSION}" == "11.3.0" ]]; then
    mpfr_version=4.1.0
    gmp_version=6.2.1
    isl_version=0.24
    mpc_version=1.2.1
else
    echo "GCC Version Not Recognized"
    exit -1
fi

# ----------------------------------------------------------------------
#                          Make Directories
# ----------------------------------------------------------------------

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# Make the build directory and cd into it
mkdir -p ${LIB_BUILD_DIR}
cd ${LIB_BUILD_DIR}

# ----------------------------------------------------------------------
#                        Download (if Needed)
# ----------------------------------------------------------------------

LOCAL_DOWNLOAD_NAME=${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.gz
REMOTE_DOWNLOAD_NAME="https://mirrors.kernel.org/gnu/gcc/gcc-${PKG_VERSION}/gcc-${PKG_VERSION}.tar.gz"

if [[ ! -f "${LOCAL_DOWNLOAD_NAME}" ]]; then
    ${DOWNLOAD_CMD} ${LOCAL_DOWNLOAD_NAME} ${REMOTE_DOWNLOAD_NAME}
fi

# ----------------------------------------------------------------------
#                            UnPack + Link
# ----------------------------------------------------------------------

# Untar the tarball
tar --strip-components 1 -xvf ${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.gz

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

# ----------------------------------------------------------------------
#                            Build + Install
# ----------------------------------------------------------------------

# Do an out of source build by making a temporary build directory
mkdir -p ${LIB_BUILD_DIR}/my_build
cd ${LIB_BUILD_DIR}/my_build

# New MacOS doesn't allow /usr/include
# A work around is to use xcode-select to find the path
SDKROOT=`xcrun --show-sdk-path --sdk macosx | xargs realpath`
XCODE_HEADERS=${SDKROOT}/usr/include
XCODE_LIBRARY=${SDKROOT}/usr/lib
XCODE_FRAMEWORK=${SDKROOT}/System/Library/Frameworks
XCODE_FLAGS="-iframework ${XCODE_FRAMEWORK}"

# Configure
${LIB_BUILD_DIR}/configure                                        \
                --prefix=${LIB_INSTALL_DIR}                       \
                --enable-languages=c,c++,fortran,lto              \
                --enable-checking=release                         \
	        --with-sysroot=${SDKROOT}                         \
                --disable-multilib

# Build
make -j${MODMAN_NPROC} BOOT_CFLAGS="${XCODE_FLAGS}" CFLAGS_FOR_TARGET="${XCODE_FLAGS}" CXXFLAGS_FOR_TARGET="${XCODE_FLAGS}"

# Install
make install

# ----------------------------------------------------------------------
#                            Create Module File
# ----------------------------------------------------------------------


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
prepend_path("PATH",              "${LIB_INSTALL_DIR}/bin")
prepend_path("DYLD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib")
prepend_path("MANPATH",           "${LIB_INSTALL_DIR}/share/man")
 
-- Environment Variables
setenv("CPP", "${LIB_INSTALL_DIR}/bin/cpp")
setenv("CC",  "${LIB_INSTALL_DIR}/bin/gcc")
setenv("CXX", "${LIB_INSTALL_DIR}/bin/g++")
setenv("FC",  "${LIB_INSTALL_DIR}/bin/gfortran")
EOF
