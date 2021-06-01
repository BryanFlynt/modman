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
export PKG=vscode
export PKG_VERSION=$1
export COMPILER=$3
export COMPILER_VERSION=$4
export MPI=$5
export MPI_VERSION=$6

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}

# Clean if they already exist
rm -rf ${LIB_INSTALL_DIR}

# Create the build directory to unpack
mkdir -p ${LIB_INSTALL_DIR}
cd ${LIB_INSTALL_DIR}

# Untar the tarball
tar --strip-components 1 -xvf ${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.gz

# Install packages
./bin/code --install-extension ms-vscode.cpptools
./bin/code --install-extension ms-vscode.cmake-tools
./bin/code --install-extension github.vscode-pull-request-github

# Create Module File
mkdir -p ${MODULE_DIR}/base/${PKG}
cat << EOF > ${MODULE_DIR}/base/${PKG}/${PKG_VERSION}.lua

help([[ ${PKG} version ${PKG_VERSION} ]])
family("vscode")

-- Conflicting modules

-- Modulepath for packages built by this compiler

-- Environment Paths
prepend_path("PATH", "${LIB_INSTALL_DIR}/bin")

-- Environment Variables
EOF
