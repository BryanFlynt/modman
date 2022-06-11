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
export PKG=llvm
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

# Make the build directory and cd into it
mkdir -p ${LIB_BUILD_DIR}
cd ${LIB_BUILD_DIR}

# ----------------------------------------------------------------------
#                        Download (if Needed)
# ----------------------------------------------------------------------

REPO_NAME=${TAR_DIR}/llvm-project
REMOTE_REPO_NAME="https://github.com/llvm/llvm-project.git"

LOCAL_DOWNLOAD_NAME=${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.xz
REMOTE_DOWNLOAD_NAME="https://github.com/llvm/llvm-project/releases/download/llvmorg-${PKG_VERSION}/llvm-project-${PKG_VERSION}.src.tar.xz"

if [ "$PKG_VERSION" == "dev" ]; then
    if [ -d "${REPO_NAME}" ]; then
        (cd ${REPO_NAME}; git pull)
    else
        (cd ${TAR_DIR}; git clone --depth 1 ${REMOTE_REPO_NAME})
    fi    
else
    if [[ ! -f "${LOCAL_DOWNLOAD_NAME}" ]]; then
        ${DOWNLOAD_CMD} ${LOCAL_DOWNLOAD_NAME} ${REMOTE_DOWNLOAD_NAME}
    fi 
fi

# ----------------------------------------------------------------------
#                            UnPack + Patch
# ----------------------------------------------------------------------

# Gather Files into ${LIB_BUILD_DIR}
if [ "$PKG_VERSION" == "dev" ]; then
    cp -r ${REPO_NAME}/* .
else
    tar --strip-components 1 -xvf ${LOCAL_DOWNLOAD_NAME}
fi

# If patch file
sed -i 's/<cstdio>/<cstdio>\n#include <limits>/' ${LIB_BUILD_DIR}/flang/runtime/unit.cpp

# ----------------------------------------------------------------------
#                            Build + Install
# ----------------------------------------------------------------------

module purge
module load cmake

# Having Read these pages
# https://groups.google.com/g/llvm-dev/c/Oj6ttXy08Fw
# https://llvm.org/docs/GettingStarted.html#getting-a-modern-host-c-toolchain
# https://llvm.org/docs/CMake.html#llvm-related-variables

# LLVM_ENABLED_PROJECTS (Cannot be dual listed in LLVM_ENABLED_RUNTIMES)
# - These get built with the system compiler (gcc, etc.)
# - Moved "libc" & "openmp" into ENABLED_RUNTIMES since those can go either way
# - - Available: clang, clang-tools-extra, cross-project-tests, flang, libc, libclc, lld, lldb, mlir, openmp, polly, pstl.
ENABLED_PROJECTS="clang;clang-tools-extra;cross-project-tests;libclc;lld;lldb;polly;pstl"

# LLVM_ENABLED_RUNTIMES (Cannot be dual listed in LLVM_ENABLED_PROJECTS)
# - These get built but the just built clang compiler
# - - Available: compiler-rt, libc, libcxx, libcxxabi, libunwind, or openmp
ENABLED_RUNTIMES="all"

# LLVM_TARGETS_TO_BUILD
# - These are all the platforms to build for
# - - Available: AArch64, AMDGPU, ARM, AVR, BPF, Hexagon, Lanai, Mips, MSP430, NVPTX, PowerPC, RISCV, Sparc, SystemZ, WebAssembly, X86, XCore
ENABLED_TARGETS="AMDGPU;NVPTX;X86"

# CLANG_DEFAULT_CXX_STDLIB
# - Default C++ std library to use
# - - Available:
# - - - <empty>   -> Platform Default
# - - - libstdc++ -> GCC standard lib
# - - - libc++    -> LLVM standard lib

# CLANG_DEFAULT_RTLIB=compiler-rt
# - Default Runtime Library for CLANG
# - - Available:
# - - - <empty>     -> Platform Default
# - - - libgcc      -> GCC runtime
# - - - compiler-rt -> LLVM runtime

# CLANG_DEFAULT_UNWINDLIB
# - Default unwind library
# - - Available:
# - - - <empty>   -> Matches Runtime Library
# - - - libgcc    -> GCC
# - - - libunwind -> LLVM

# Detect if we can find Ninja
if ninja --help || module load ninja; then
    cmake \
        -D CMAKE_BUILD_TYPE=Release                 \
        -D CMAKE_INSTALL_PREFIX=${LIB_INSTALL_DIR}  \
        -D LLVM_ENABLE_PROJECTS=${ENABLED_PROJECTS} \
        -D LLVM_ENABLE_RUNTIMES=${ENABLED_RUNTIMES} \
        -D LLVM_TARGETS_TO_BUILD=${ENABLED_TARGETS} \
        -D CLANG_DEFAULT_CXX_STDLIB=libc++          \
        -D CLANG_DEFAULT_RTLIB=compiler-rt          \
        -G "Ninja"                                  \
        ${LIB_BUILD_DIR}/llvm
    
    ninja
    ninja install
else
    cmake \
        -D CMAKE_BUILD_TYPE=Release                 \
        -D CMAKE_INSTALL_PREFIX=${LIB_INSTALL_DIR}  \
        -D LLVM_ENABLE_PROJECTS=${ENABLED_PROJECTS} \
        -D LLVM_ENABLE_RUNTIMES=${ENABLED_RUNTIMES} \
        -D LLVM_TARGETS_TO_BUILD=${ENABLED_TARGETS} \
        -D CLANG_DEFAULT_CXX_STDLIB=libc++          \
        -D CLANG_DEFAULT_RTLIB=compiler-rt          \
        -G "Ninja"                                  \
        ${LIB_BUILD_DIR}/llvm

    make
    make install
fi


# ----------------------------------------------------------------------
#                            Create Module File
# ----------------------------------------------------------------------

# Get location of libstdc++ files for the GCC compiler we used
#gnu_c_compiler=${CC}
#gnu_bin_dir=$(dirname ${CC})
#gnu_base_name=$(dirname ${gnu_bin_dir})

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
-- prepend_path("PATH",            "${gnu_base_name}/bin")
-- prepend_path("LD_LIBRARY_PATH", "${gnu_base_name}/lib")
-- prepend_path("LD_LIBRARY_PATH", "${gnu_base_name}/lib64")

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
