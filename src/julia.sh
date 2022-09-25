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
export PKG=julia
export PKG_VERSION=$1

# ----------------------------------------------------------------------
#                          Make Directories
# ----------------------------------------------------------------------

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# Make the build + install directory
mkdir -p ${LIB_BUILD_DIR}
mkdir -p ${LIB_INSTALL_DIR}

# ----------------------------------------------------------------------
#                        Download (if Needed)
# ----------------------------------------------------------------------

LOCAL_DOWNLOAD_NAME=${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.gz
REMOTE_DOWNLOAD_NAME="https://github.com/JuliaLang/julia/archive/refs/tags/v${PKG_VERSION}.tar.gz"

if [[ ! -f "${LOCAL_DOWNLOAD_NAME}" ]]; then
    ${DOWNLOAD_CMD} ${LOCAL_DOWNLOAD_NAME} ${REMOTE_DOWNLOAD_NAME}
fi 

# ----------------------------------------------------------------------
#                            UnPack + Patch
# ----------------------------------------------------------------------

# UnPack Directly into Intallation
cd ${LIB_INSTALL_DIR}
tar --strip-components 1 -xvf ${LOCAL_DOWNLOAD_NAME}

# ----------------------------------------------------------------------
#                            Build + Install
# ----------------------------------------------------------------------

module purge
module load cmake

# Build Directly into Intallation
cd ${LIB_INSTALL_DIR}
make

# ----------------------------------------------------------------------
#                            Create Module File
# ----------------------------------------------------------------------

# Create Module File
mkdir -p ${MODULE_DIR}/base/${PKG}
cat << EOF > ${MODULE_DIR}/base/${PKG}/${PKG_VERSION}.lua

help([[ ${PKG} version ${PKG_VERSION} ]])
family("julia")

-- Conflicting modules

-- Modulepath for packages built by this compiler
prepend_path("MODULEPATH", "${MODULE_DIR}/compiler/${PKG}/${PKG_VERSION}")

-- Environment Paths
prepend_path("PATH",    "${LIB_INSTALL_DIR}")
-- prepend_path("PATH", "${LIB_INSTALL_DIR}/usr/bin")

-- Environment Variables
setenv("JULIA_BINDIR",  "${LIB_INSTALL_DIR}")
setenv("JULIA_PROJECT", "@")
EOF
