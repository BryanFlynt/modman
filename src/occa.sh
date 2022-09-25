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
export PKG=occa
export PKG_VERSION=$1
export COMPILER=$2
export COMPILER_VERSION=$3

# Load build environment
module purge
module load cmake
module load ${COMPILER}/${COMPILER_VERSION}
module load cuda/11.7.1

# ----------------------------------------------------------------------
#                          Clean Directories
# ----------------------------------------------------------------------

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}/${COMPILER}/${COMPILER_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}/${COMPILER}/${COMPILER_VERSION}

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# ----------------------------------------------------------------------
#                        Download (if Needed)
# ----------------------------------------------------------------------

REPO_NAME=${TAR_DIR}/occa
REMOTE_REPO_NAME="https://github.com/libocca/occa.git"

# Get/Update Clean Repo Version
if [ -d "${REPO_NAME}" ]; then
    (cd ${REPO_NAME}; git pull)
else
    (cd ${TAR_DIR}; git clone --depth 1 ${REMOTE_REPO_NAME})
fi

# ----------------------------------------------------------------------
#                          Make Directories
# ----------------------------------------------------------------------

# Copy clean repo to build directory
mkdir -p ${BUILD_DIR}/${PKG}/${PKG_VERSION}/${COMPILER}; cp -r ${REPO_NAME} ${LIB_BUILD_DIR}

# Checkout Taged Version
cd ${LIB_BUILD_DIR}
git fetch --all --tags
git checkout tags/v${PKG_VERSION}

# ----------------------------------------------------------------------
#                            Build + Install
# ----------------------------------------------------------------------

# NOTE:
# OCCA Uses BUILD_DIR internally as the directory to build but we have already
# specified that as the ModMan build directory so things get confusing unless
# we explicitly specify it on the configure line.
#
BUILD_DIR=${LIB_BUILD_DIR}/build INSTALL_DIR=${LIB_INSTALL_DIR} ENABLE_FORTRAN="ON" BUILD_TYPE="Release" ./configure-cmake.sh

cmake --build build --parallel ${MODMAN_NPROC}
cmake --install build --prefix ${LIB_INSTALL_DIR}

# ----------------------------------------------------------------------
#                            Create Module File
# ----------------------------------------------------------------------

# Create Module File
mkdir -p ${MODULE_DIR}/compiler/${COMPILER}/${COMPILER_VERSION}/${PKG}
cat << EOF > ${MODULE_DIR}/compiler/${COMPILER}/${COMPILER_VERSION}/${PKG}/${PKG_VERSION}.lua

help([[ ${PKG} version ${PKG_VERSION} ]])
family("occa")

-- Conflicts

-- Dependencies
prereq("${COMPILER}/${COMPILER_VERSION}")

-- Environment Paths
prepend_path("PATH",               "${LIB_INSTALL_DIR}/bin")
prepend_path("LIBRARY_PATH",       "${LIB_INSTALL_DIR}/lib")
prepend_path("LD_LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib")
prepend_path("INCLUDE",            "${LIB_INSTALL_DIR}/include")
prepend_path("C_INCLUDE_PATH",     "${LIB_INSTALL_DIR}/include")
prepend_path("CPLUS_INCLUDE_PATH", "${LIB_INSTALL_DIR}/include")

-- Environment Variables
setenv("OCCA_ROOT",             "${LIB_INSTALL_DIR}")
setenv("OCCA_DIR",              "${LIB_INSTALL_DIR}")
setenv("OCCA_INSTALL_DIR",      "${LIB_INSTALL_DIR}")
EOF
