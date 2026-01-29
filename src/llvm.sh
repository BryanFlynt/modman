#!/bin/bash -l

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# ===================================================
#           Already set Variables (build.sh)
# ===================================================

#
# From build.sh
#
# PKG              = Package being installed (cmake, etc.)
# PKG_VERSION      = Version of package (4.0.1, etc.)
# COMPILER         = Compiler to use (gcc, etc.)
# COMPILER_VERSION = Version of compiler to use (15.2.0, etc.)
# MPI              = MPI to use (opnempi, etc.)
# MPI_VERSION      = Version of MPI to use (5.0.2, etc.)
#
# MODPKG_DOWNLOAD_DIR = Directory to download package into
# MODPKG_BUILD_DIR    = Directory to build package within
# MODPKG_INSTALL_DIR  = Directory to install package within
# MODPKG_MODULE_DIR   = Directory to place module file

# Number of threads to build
NTHREAD=8

# Load build environment
module purge
module load cmake
#module load gcc  # We need a newish compiler with libstdc++.co.*

# Clean if they already exist
rm -rf ${MODPKG_BUILD_DIR}
rm -rf ${MODPKG_INSTALL_DIR}

# ===================================================
#                       Download
# ===================================================

URL_ROOT="https://github.com/llvm/llvm-project/releases/download"
URL_DIR="llvmorg-${PKG_VERSION}"
URL_NAME="llvm-project-${PKG_VERSION}.src"
URL_EXT="tar.xz"

URL_DOWNLOAD="${URL_ROOT}/${URL_DIR}/${URL_NAME}.${URL_EXT}"
URL_TARGET="${MODPKG_DOWNLOAD_DIR}/${URL_NAME}.${URL_EXT}"

if [ ! -f "${URL_TARGET}" ]; then
    wget ${URL_DOWNLOAD} --directory-prefix=${MODPKG_DOWNLOAD_DIR}
fi

# ===================================================
#                        UnPack
# ===================================================

# Create Build Directory
mkdir -p ${MODPKG_BUILD_DIR}
cd ${MODPKG_BUILD_DIR}

# Untar the tarball
tar --strip-components 1 -xvf ${URL_TARGET}

# ===================================================
#                    Build + Install
# ===================================================

# Passing any bad name will provide the actual list of available flags
# - Names should not overlap between the project and runtime lists
# - Prefer the runtime option if available
#
# ENABLED_PROJECTS=junk
# ENABLED_RUNTIMES=junk
#
# 21.1.8 from llvm/CMakeLists.txt
#
# all = LLVM_ALL_PROJECTS="bolt;clang;clang-tools-extra;compiler-rt;cross-project-tests;libclc;lld;lldb;mlir;openmp;polly"
# LLVM_EXTRA_PROJECTS="flang;libc
#
# all = LLVM_DEFAULT_RUNTIMES="libcxx;libcxxabi;libunwind"
# LLVM_SUPPORTED_RUNTIMES="libc;libunwind;libcxxabi;libcxx;compiler-rt;openmp;llvm-libgcc;offload;flang-rt;libclc"
#
#ENABLED_PROJECTS="all"
#ENABLED_RUNTIMES="all"

ENABLED_PROJECTS="bolt;clang;clang-tools-extra;cross-project-tests;lld;lldb;mlir;polly;flang"
ENABLED_RUNTIMES="libc;libunwind;libcxxabi;libcxx;compiler-rt;openmp;flang-rt;libclc"

# Using CMake to create out of source build with -B flag
cd ${MODPKG_BUILD_DIR}

# Detect if we can find Ninja
if ninja --help || module load ninja; then
    cmake -S llvm \
          -B build_by_modman \
          -G "Ninja" \
          -D LLVM_TARGETS_TO_BUILD=host \
          -D LLVM_ENABLE_PROJECTS=${ENABLED_PROJECTS} \
          -D LLVM_ENABLE_RUNTIMES=${ENABLED_RUNTIMES} \
          -D CMAKE_INSTALL_PREFIX=${MODPKG_INSTALL_DIR} \
          -D CMAKE_BUILD_TYPE=Release
else
    cmake -S llvm \
          -B build_by_modman \
          -G "Unix Makefiles" \
          -D LLVM_TARGETS_TO_BUILD=host \
          -D LLVM_ENABLE_PROJECTS=${ENABLED_PROJECTS} \
          -D LLVM_ENABLE_RUNTIMES=${ENABLED_RUNTIMES} \
          -D CMAKE_INSTALL_PREFIX=${MODPKG_INSTALL_DIR} \
          -D CMAKE_BUILD_TYPE=Release
fi
cmake --build build_by_modman -j ${NTHREAD}
cmake --install build_by_modman

# ===================================================
#                       Module File
# ===================================================

# Get location of libstdc++ files for the GCC compiler we used
#
# Clang uses GCC's libstdc++ as its default C++ standard library on Linux
# Force libstdc++ (Default)  =>  -stdlib=libstdc++
# Force libc++.so.*          =>  -stdlib=libc++
#
if [ -z ${CC+x} ]; then
    stdlib_base_dir=/usr/lib64
else
    sys_c_compiler=${CC}
    sys_bin_dir=$(dirname ${CC})
    stdlib_base_dir=$(dirname ${sys_bin_dir})/lib64
fi   

# Create Module File
mkdir -p ${MODPKG_MODULE_DIR}
cat << EOF > ${MODPKG_MODULE_DIR}/${PKG_VERSION}.lua

help([[ ${PKG} version ${PKG_VERSION} ]])
family("compiler")

-- Conflicting modules
conflict("gcc")

-- Modulepath for packages built by this compiler
prepend_path("MODULEPATH", "${MODMAN_MODULE_DIR}/compiler/${PKG}/${PKG_VERSION}")

-- Point at Latest GCC Compiler (libstdc++)
prepend_path("LD_LIBRARY_PATH", "${stdlib_base_dir}")

-- Environment Variables
local base = "${MODPKG_INSTALL_DIR}"

setenv("CPP", pathJoin(base, "bin/clang-cpp""))
setenv("CC",  pathJoin(base, "bin/clang"))
setenv("CXX", pathJoin(base, "bin/clang++"))
setenv("FC",  pathJoin(base, "bin/flang"))

-- Environment Paths
prepend_path("PATH",            pathJoin(base, "bin"))
prepend_path("LIBRARY_PATH",    pathJoin(base, "lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base, "lib"))
EOF
