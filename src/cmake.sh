#!/bin/bash -l
#
# =========================================
#
# Script is always called as:
# > <package>.sh <package_version> <compiler> <compiler_version> <mpi> <mpi_version>
#
# =========================================

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

# Discover the machine type we are on
file_name=${PKG}-${PKG_VERSION}
if [ "$(uname)" == "Darwin" ]; then
    tar_file_name=${file_name}-macos-universal.tar.gz      
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    tar_file_name=${file_name}-linux-x86_64.tar.gz
fi

# Create the build directory to unpack
mkdir -p ${BUILD_DIR}/${PKG}/${PKG_VERSION}
cd ${BUILD_DIR}/${PKG}/${PKG_VERSION}

# Untar the tarball
tar --strip-components 1 -xzvf ${TAR_DIR}/${tar_file_name}

# Create installation directory
mkdir -p ${INSTALL_DIR}/${PKG}/${PKG_VERSION}

# Move Unpacked into installation directory
mv ${BUILD_DIR}/${PKG}/${PKG_VERSION}/* ${INSTALL_DIR}/${PKG}/${PKG_VERSION}/.

# Create Module File
mkdir -p ${MODULE_DIR}/base/${PKG}
cat << EOF > ${MODULE_DIR}/base/${PKG}/${PKG_VERSION}.lua

help([[ ${PKG} version ${PKG_VERSION} ]])
family("cmake")

-- Conflicting modules

-- Modulepath for packages built by this compiler

-- Environment Paths
prepend_path("PATH",            "${LIB_INSTALL_DIR}/bin")

-- Environment Variables
EOF
