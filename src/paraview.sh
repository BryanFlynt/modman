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
export PKG=paraview
export PKG_VERSION=$1
export COMPILER=$3
export COMPILER_VERSION=$4
export MPI=$5
export MPI_VERSION=$6

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# Discover the filename
if [ "$(uname)" == "Darwin" ]; then
    tar_file_name=$(basename -- "$(find ${TAR_DIR} -name ParaView-${PKG_VERSION}*.dmg)")      
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    tar_file_name=$(basename -- "$(find ${TAR_DIR} -name ParaView-${PKG_VERSION}*.tar.gz)")
fi

# Create the build directory to unpack
mkdir -p ${LIB_BUILD_DIR}
cd ${LIB_BUILD_DIR}

# Untar the tarball
tar --strip-components 1 -xzvf ${TAR_DIR}/${tar_file_name}

# Create installation directory
mkdir -p ${LIB_INSTALL_DIR}

# Move Unpacked into installation directory
mv ${LIB_BUILD_DIR}/* ${LIB_INSTALL_DIR}/.

# Create Module File
mkdir -p ${MODULE_DIR}/base/${PKG}
cat << EOF > ${MODULE_DIR}/base/${PKG}/${PKG_VERSION}.lua

help([[ ${PKG} version ${PKG_VERSION} ]])
family("paraview")

-- Conflicting modules

-- Modulepath for packages built by this compiler

-- Environment Paths
prepend_path("PATH",     "${LIB_INSTALL_DIR}/bin")

-- Environment Variables
EOF
