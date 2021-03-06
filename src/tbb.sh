#!/bin/bash -l

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# Set the package name
export PKG=tbb
export PKG_VERSION=$1
export COMPILER=$2
export COMPILER_VERSION=$3

# Load build environment
module purge
module load cmake
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
tar --strip-components 1 -xvf ${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.*

# Do an out of source build by making a temporary build directory
mkdir -p ${LIB_BUILD_DIR}/my_build
cd ${LIB_BUILD_DIR}/my_build

# Configure
cmake \
    -D TBB_STRICT=OFF \
    -D CMAKE_INSTALL_PREFIX=${LIB_INSTALL_DIR} \
    -D CMAKE_BUILD_TYPE=Release \
    -G "Unix Makefiles" \
    ${LIB_BUILD_DIR}

# Build
make -j 8

# Install
make install
#cmake -DCOMPONENT=devel -P cmake_install.cmake


# Create Module File
mkdir -p ${MODULE_DIR}/compiler/${COMPILER}/${COMPILER_VERSION}/${PKG}
cat << EOF > ${MODULE_DIR}/compiler/${COMPILER}/${COMPILER_VERSION}/${PKG}/${PKG_VERSION}.lua

help([[ ${PKG} version ${PKG_VERSION} ]])
family("tbb")

-- Conflicts

-- Dependencies
prereq("${COMPILER}/${COMPILER_VERSION}")

-- Modulepath for packages built by this compiler
prepend_path("MODULEPATH", "${MODULE_DIR}/mpi/${PKG}/${PKG_VERSION}/${COMPILER}/${COMPILER_VERSION}")

-- Environment Paths
prepend_path("CPATH",           "${LIB_INSTALL_DIR}/include")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib64")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib64")

-- Environment Variables
setenv("TBB_ROOT",             "${LIB_INSTALL_DIR}")
setenv("TBB_HOME",             "${LIB_INSTALL_DIR}")
EOF
