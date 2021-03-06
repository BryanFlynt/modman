#!/bin/bash -l

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# Set the package name
export PKG=openblas
export PKG_VERSION=$1
export COMPILER=$2
export COMPILER_VERSION=$3

# Load build environment
module purge
module load ${COMPILER}/${COMPILER_VERSION}

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}/${COMPILER}/${COMPILER_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}/${COMPILER}/${COMPILER_VERSION}

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# Make the build directory and cd into it
mkdir -p ${LIB_BUILD_DIR}
cd ${LIB_BUILD_DIR}

# Unpack the Source
tar --strip-components 1 -xzvf ${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.gz

# Get number of cores on system
NUM_HYPER_THREADS=$(grep -c ^processor /proc/cpuinfo)
NUM_PHYSICAL_THREADS=$(grep ^cpu\\scores /proc/cpuinfo | uniq |  awk '{print $4}')

# Build it
make USE_OPENMP=1 NUM_THREADS=${NUM_HYPER_THREADS} PREFIX=${LIB_INSTALL_DIR} 
make USE_OPENMP=1 NUM_THREADS=${NUM_HYPER_THREADS} PREFIX=${LIB_INSTALL_DIR} install

# Create Module File
mkdir -p ${MODULE_DIR}/compiler/${COMPILER}/${COMPILER_VERSION}/${PKG}
cat << EOF > ${MODULE_DIR}/compiler/${COMPILER}/${COMPILER_VERSION}/${PKG}/${PKG_VERSION}.lua
help([[ ${PKG} version ${PKG_VERSION} ]])
family("blas")

-- Conflicts

-- Dependencies
prereq("${COMPILER}/${COMPILER_VERSION}")

-- Modulepath for packages built with this library

-- Environment Paths
prepend_path("CPATH",           "${LIB_INSTALL_DIR}/include")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib64")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib64")

-- Environment Variables
setenv("BLAS_ROOT",             "${LIB_INSTALL_DIR}")
EOF
