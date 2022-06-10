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
export PKG=ninja
export PKG_VERSION=$1
export COMPILER=$2
export COMPILER_VERSION=$3

# Load build environment
module purge
module load cmake

# ----------------------------------------------------------------------
#                           Make Directories
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
#                         Download (if Needed)
# ----------------------------------------------------------------------

LOCAL_DOWNLOAD_NAME=${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.gz
REMOTE_DOWNLOAD_NAME="https://github.com/ninja-build/ninja/archive/refs/tags/v${PKG_VERSION}.tar.gz"

if [[ ! -f "${LOCAL_DOWNLOAD_NAME}" ]]; then
    ${DOWNLOAD_CMD} ${LOCAL_DOWNLOAD_NAME} ${REMOTE_DOWNLOAD_NAME}
fi

# ----------------------------------------------------------------------
#                                UnPack
# ----------------------------------------------------------------------

# Unpack the Source
tar --strip-components 1 -xvf ${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.*

# ----------------------------------------------------------------------
#                            Build + Install
# ----------------------------------------------------------------------

# Do an out of source build by making a temporary build directory
mkdir -p ${LIB_BUILD_DIR}/my_build
cd ${LIB_BUILD_DIR}/my_build

# Configure, Build Install
cmake \
    -D CMAKE_INSTALL_PREFIX=${LIB_INSTALL_DIR} \
    -D CMAKE_BUILD_TYPE=Release \
    -G "Unix Makefiles" \
    ${LIB_BUILD_DIR}

make -j
./ninja_test
make install

# ----------------------------------------------------------------------
#                            Create Module File
# ----------------------------------------------------------------------

# Create Module File
mkdir -p ${MODULE_DIR}/base/${PKG}
cat << EOF > ${MODULE_DIR}/base/${PKG}/${PKG_VERSION}.lua
help([[ ${PKG} version ${PKG_VERSION} ]])
family("ninja")

-- Conflicts

-- Dependencies

-- Modulepath for packages built with this library

-- Environment Paths
prepend_path("PATH",            "${LIB_INSTALL_DIR}/bin")

-- Environment Variables
setenv("NINJA_ROOT",            "${LIB_INSTALL_DIR}")
EOF
