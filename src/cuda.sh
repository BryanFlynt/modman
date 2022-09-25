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
export PKG=cuda
export PKG_VERSION=$1

# ----------------------------------------------------------------------
#                          Make Directories
# ----------------------------------------------------------------------

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}

# Remove if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# ReMake the build + install directory
mkdir -p ${LIB_BUILD_DIR}
mkdir -p ${LIB_INSTALL_DIR}
cd ${LIB_BUILD_DIR}

# ----------------------------------------------------------------------
#                        Download (if Needed)
# ----------------------------------------------------------------------

LOCAL_DOWNLOAD_NAME=${TAR_DIR}/${PKG}-${PKG_VERSION}.run
REMOTE_DOWNLOAD_NAME="https://developer.download.nvidia.com/compute/cuda/${PKG_VERSION}/local_installers/cuda_${PKG_VERSION}_515.65.01_linux.run"

${DOWNLOAD_CMD} ${LOCAL_DOWNLOAD_NAME} ${REMOTE_DOWNLOAD_NAME}

# ----------------------------------------------------------------------
#                            Build + Install
# ----------------------------------------------------------------------

# Install
sh ${TAR_DIR}/${PKG}-${PKG_VERSION}*.run --silent --toolkit --installpath=${LIB_INSTALL_DIR} --no-man-page

# ----------------------------------------------------------------------
#                            Create Module File
# ----------------------------------------------------------------------

# Create Module File
mkdir -p ${MODULE_DIR}/base/${PKG}
cat << EOF > ${MODULE_DIR}/base/${PKG}/${PKG_VERSION}.lua

help([[ ${PKG} version ${PKG_VERSION} ]])
family("cuda")

-- Conflicting modules

-- Modulepath for packages built by this compiler

-- Environment Paths
prepend_path("PATH",            "${LIB_INSTALL_DIR}/bin")

-- Environment Variables
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib64")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib64")

setenv("CUDA_ROOT",             "${LIB_INSTALL_DIR}")
setenv("OpenCL_ROOT",           "${LIB_INSTALL_DIR}")
EOF
