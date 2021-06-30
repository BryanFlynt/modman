#!/bin/bash -l

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# Set the package name
export PKG=anaconda
export PKG_VERSION=$1

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

# Run the Script (Base ToolKit)
bash ${TAR_DIR}/${PKG}-${PKG_VERSION}.sh -b -fp ${LIB_INSTALL_DIR}

# Module
mkdir -p ${MODULE_DIR}/base/${PKG}
cat << EOF > ${MODULE_DIR}/base/${PKG}/${PKG_VERSION}.lua
help([[ ${PKG} version ${PKG_VERSION} ]])
family("python")

-- Conflicting modules

-- Modulepath for packages built by this compiler

-- Environment Paths
prepend_path("PATH",     "${LIB_INSTALL_DIR}/bin")

-- Environment Variables
setenv("ANACONDA_ROOT",  "${LIB_INSTALL_DIR}")
EOF
