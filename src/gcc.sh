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

# Clean if they already exist
rm -rf ${MODPKG_BUILD_DIR}
rm -rf ${MODPKG_INSTALL_DIR}

# ===================================================
#                       Download
# ===================================================

URL_ROOT="https://mirrors.kernel.org/gnu/gcc"
URL_DIR="${PKG}-${PKG_VERSION}"
URL_NAME="${PKG}-${PKG_VERSION}"
URL_EXT="tar.gz"

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
tar --strip-components 1 -xzvf ${URL_TARGET}

# Download prerequisites
./contrib/download_prerequisites

# ===================================================
#                    Build + Install
# ===================================================

# Do an out of source build by making a temporary build directory
mkdir -p ${MODPKG_BUILD_DIR}/build_by_modman
cd ${MODPKG_BUILD_DIR}/build_by_modman

# Configure
${MODPKG_BUILD_DIR}/configure                           \
                   --prefix=${MODPKG_INSTALL_DIR}       \
                   --enable-bootstrap                   \
                   --enable-languages=c,c++,fortran,lto \
                   --enable-checking=release            \
                   --enable-threads=posix               \
                   --disable-multilib

# Build
make -j ${NTHREAD}

# Install
make install

# ===================================================
#                       Module File
# ===================================================

# Create Module File
mkdir -p ${MODPKG_MODULE_DIR}
cat << EOF > ${MODPKG_MODULE_DIR}/${PKG_VERSION}.lua

help([[ ${PKG} version ${PKG_VERSION} ]])
family("compiler")

-- Conflicting modules
conflict("llvm")

-- Modulepath for packages built by this compiler
prepend_path("MODULEPATH", "${MODMAN_MODULE_DIR}/compiler/${PKG}/${PKG_VERSION}")

-- Environment Variables
local base = "${MODPKG_INSTALL_DIR}"

setenv("CPP", pathJoin(base, "bin/cpp"))
setenv("CC",  pathJoin(base, "bin/gcc"))
setenv("CXX", pathJoin(base, "bin/g++"))
setenv("FC",  pathJoin(base, "bin/gfortran"))

-- Environment Paths
prepend_path("PATH",            pathJoin(base, "bin"))
prepend_path("LIBRARY_PATH",    pathJoin(base, "lib64"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base, "lib64"))
prepend_path("MANPATH",         pathJoin(base, "share/man")) 
EOF
