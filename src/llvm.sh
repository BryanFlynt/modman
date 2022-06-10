#!/bin/bash -l

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# Set the package name
export PKG=llvm
export PKG_VERSION=$1

# Load build environment
module purge
module load cmake
#module load gcc    # Requires compiler to build
module load llvm    # Requires compiler to build

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}

##### -- Start -- Comment out Build for Failed Parallel Build
## : <<'END'

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# Make the build directory and cd into it
mkdir -p ${LIB_BUILD_DIR}
cd ${LIB_BUILD_DIR}

# Untar the tarball
tar --strip-components 1 -xvf ${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.*

# If version 12.0.0 then patch file
#if [ ${PKG_VERSION} -eq "12.0.0" ]; then
    sed -i 's/<cstdio>/<cstdio>\n#include <limits>/' ${LIB_BUILD_DIR}/flang/runtime/unit.cpp
#fi

# Do an out of source build by making a temporary build directory
mkdir -p ${LIB_BUILD_DIR}/my_build
cd ${LIB_BUILD_DIR}/my_build

#ENABLED_PROJECTS='clang;flang;clang-tools-extra;libcxx;libcxxabi;lld;poly;openmp'
#ENABLED_PROJECTS='clang;flang;clang-tools-extra;libcxx;libcxxabi;libunwind;libc;libclc;lld;lldb;openmp;polly;pstl'
ENABLED_PROJECTS='all'

# Detect if we can find Ninja
if ninja --help || module load ninja; then
    cmake \
        -D LLVM_ENABLE_PROJECTS=${ENABLED_PROJECTS} \
        -D CMAKE_INSTALL_PREFIX=${LIB_INSTALL_DIR} \
        -D CMAKE_BUILD_TYPE=Release \
        -G "Ninja" \
        ${LIB_BUILD_DIR}/llvm
        
    ninja
    ninja install
else
    cmake \
        -D LLVM_ENABLE_PROJECTS=${ENABLED_PROJECTS} \
        -D CMAKE_INSTALL_PREFIX=${LIB_INSTALL_DIR} \
        -D CMAKE_BUILD_TYPE=Release \
        -G "Unix Makefiles" \
        ${LIB_BUILD_DIR}/llvm

    make
    make install
fi

## END
## cd ${LIB_BUILD_DIR}/my_build
## module load ninja
## ninja
## ninja install
##### -- Finish -- Comment out Build for Failed Parallel Build


# Get location of libstdc++ files for the GCC compiler we used
gnu_c_compiler=${CC}
gnu_bin_dir=$(dirname ${CC})
gnu_base_name=$(dirname ${gnu_bin_dir})

# Create Module File
mkdir -p ${MODULE_DIR}/base/${PKG}
cat << EOF > ${MODULE_DIR}/base/${PKG}/${PKG_VERSION}.lua

help([[ ${PKG} version ${PKG_VERSION} ]])
family("compiler")

-- Conflicting modules
conflict("gcc")

-- Modulepath for packages built by this compiler
prepend_path("MODULEPATH", "${MODULE_DIR}/compiler/${PKG}/${PKG_VERSION}")

-- Point at Latest GCC Compiler (libstdc++)
prepend_path("PATH",            "${gnu_base_name}/bin")
prepend_path("LD_LIBRARY_PATH", "${gnu_base_name}/lib")
prepend_path("LD_LIBRARY_PATH", "${gnu_base_name}/lib64")

-- Environment Paths
prepend_path("PATH",            "${LIB_INSTALL_DIR}/bin")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib64")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib64")

-- Environment Variables
setenv("CPP", "${LIB_INSTALL_DIR}/bin/clang-cpp")
setenv("CC",  "${LIB_INSTALL_DIR}/bin/clang")
setenv("CXX", "${LIB_INSTALL_DIR}/bin/clang++")
setenv("FC",  "${LIB_INSTALL_DIR}/bin/flang")
EOF
