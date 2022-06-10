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

# Set the variables
export PKG=cmake
export PKG_VERSION=$1
export COMPILER=$3
export COMPILER_VERSION=$4
export MPI=$5
export MPI_VERSION=$6

# ----------------------------------------------------------------------
#                        Download (if Needed)
# ----------------------------------------------------------------------

LOCAL_DOWNLOAD_NAME=${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.gz

if [[ "$OSTYPE" == "linux"* ]]; then
    REMOTE_DOWNLOAD_NAME="https://github.com/Kitware/CMake/releases/download/v${PKG_VERSION}/cmake-${PKG_VERSION}-linux-x86_64.tar.gz"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    REMOTE_DOWNLOAD_NAME="https://github.com/Kitware/CMake/releases/download/v${PKG_VERSION}/cmake-${PKG_VERSION}-macos-universal.tar.gz"
fi

if [[ ! -f "${LOCAL_DOWNLOAD_NAME}" ]]; then
    ${DOWNLOAD_CMD} ${LOCAL_DOWNLOAD_NAME} ${REMOTE_DOWNLOAD_NAME}
fi

# ----------------------------------------------------------------------
#                            UnPack + Install
# ----------------------------------------------------------------------

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# Create the build directory to unpack
mkdir -p ${LIB_BUILD_DIR}
cd ${LIB_BUILD_DIR}

# Untar the tarball
tar --strip-components 1 -xvf ${LOCAL_DOWNLOAD_NAME}

# Create installation directory
mkdir -p ${LIB_INSTALL_DIR}

# Move Unpacked into installation directory
mv ${LIB_BUILD_DIR}/* ${LIB_INSTALL_DIR}/.

# ----------------------------------------------------------------------
#                            Create Module File
# ----------------------------------------------------------------------


mkdir -p ${MODULE_DIR}/base/${PKG}
cat << EOF > ${MODULE_DIR}/base/${PKG}/${PKG_VERSION}.lua

help([[ ${PKG} version ${PKG_VERSION} ]])
family("cmake")

-- Conflicting modules

-- Modulepath for packages built by this compiler

-- Environment Paths
prepend_path("PATH", "${LIB_INSTALL_DIR}/bin")

-- Environment Variables
EOF
