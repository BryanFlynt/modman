#!/bin/bash -l

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# Set the package name
export PKG=ninja
export PKG_VERSION=$1
export COMPILER=$2
export COMPILER_VERSION=$3

# Load build environment
module purge
module load cmake
module load gcc

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

# Do an out of source build by making a temporary build directory
mkdir -p ${LIB_BUILD_DIR}/my_build
cd ${LIB_BUILD_DIR}/my_build

# Configure, Build Install
cmake \
    -D CMAKE_INSTALL_PREFIX=${LIB_INSTALL_DIR} \
    -D CMAKE_BUILD_TYPE=Release \
    -G "Unix Makefiles" \
    ${LIB_BUILD_DIR}

make -j `nproc`
./ninja_test
make install

# Get location of libstdc++ files for the GCC compiler we used
gnu_c_compiler=${CC}
gnu_bin_dir=$(dirname ${CC})
gnu_base_name=$(dirname ${gnu_bin_dir})

# Create Module File
mkdir -p ${MODULE_DIR}/base/${PKG}
cat << EOF > ${MODULE_DIR}/base/${PKG}/${PKG_VERSION}.lua
help([[ ${PKG} version ${PKG_VERSION} ]])
family("ninja")

-- Conflicts

-- Dependencies

-- Modulepath for packages built with this library

-- Point at GCC Compiler we Built With (libstdc++)
prepend_path("LD_LIBRARY_PATH", "${gnu_base_name}/lib")
prepend_path("LD_LIBRARY_PATH", "${gnu_base_name}/lib64")

-- Environment Paths
prepend_path("PATH",            "${LIB_INSTALL_DIR}/bin")

-- Environment Variables
setenv("NINJA_ROOT",            "${LIB_INSTALL_DIR}")
EOF
