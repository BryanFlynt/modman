#!/bin/bash -l

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# Set the package name
export PKG=astyle
export PKG_VERSION=$1
export COMPILER=$2
export COMPILER_VERSION=$3

# Load build environment
module purge
module load cmake
module load ${COMPILER}/${COMPILER_VERSION}

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# Make the build directory and cd into it
mkdir -p ${LIB_BUILD_DIR}
cd ${LIB_BUILD_DIR}

# Unpack the Source
tar --strip-components 1 -xvf ${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.*

# Configure
cmake .

# Build it
make

# Move it to the install directory
mkdir -p ${LIB_INSTALL_DIR}
mv astyle ${LIB_INSTALL_DIR}/.

# Create Module File
mkdir -p ${MODULE_DIR}/base/${PKG}
cat << EOF > ${MODULE_DIR}/base/${PKG}/${PKG_VERSION}.lua
help([[ ${PKG} version ${PKG_VERSION} ]])
family("astyle")

-- Conflicts

-- Dependencies
depends_on("${COMPILER}/${COMPILER_VERSION}")

-- Modulepath for packages built with this library

-- Environment Paths
prepend_path("PATH",            "${LIB_INSTALL_DIR}")

-- Environment Variables
setenv("ASTYLE_ROOT",           "${LIB_INSTALL_DIR}")
EOF
