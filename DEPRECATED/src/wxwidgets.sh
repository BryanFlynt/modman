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
# PKG                  = Package being installed (cmake, etc.)
# PKG_VERSION          = Version of package (4.0.1, etc.)
# COMPILER             = Compiler to use (gcc, etc.)
# COMPILER_VERSION     = Version of compiler to use (15.2.0, etc.)
# MPI_COMPILER         = MPI to use (opnempi, etc.)
# MPI_COMPILER_VERSION = Version of MPI to use (5.0.2, etc.)
#
# MODPKG_DOWNLOAD_DIR = Directory to download package into
# MODPKG_BUILD_DIR    = Directory to build package within
# MODPKG_INSTALL_DIR  = Directory to install package within
# MODPKG_MODULE_DIR   = Directory to place module file

# Number of threads to build
NTHREAD=8

# Load build environment
module purge
module load ${COMPILER}/${COMPILER_VERSION}
module load cmake

# Clean if they already exist
rm -rf ${MODPKG_BUILD_DIR}
rm -rf ${MODPKG_INSTALL_DIR}

# ===================================================
#                       Download
# ===================================================

# Split version into parts 
IFS='.' read -ra PARTS <<< "${PKG_VERSION}"  # PARTS=("2" "4" "1")

URL_ROOT="https://github.com/wxWidgets/wxWidgets/releases/download"
URL_DIR="v${PKG_VERSION}"
URL_NAME="wxWidgets-${PKG_VERSION}"
URL_EXT="tar.bz2"

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

# Do an out of source build by making a temporary build directory
mkdir -p ${MODPKG_BUILD_DIR}/build_by_modman
cd ${MODPKG_BUILD_DIR}/build_by_modman


cmake -G "Unix Makefiles" \
      -D CMAKE_INSTALL_PREFIX=${MODPKG_INSTALL_DIR} \
      -D CMAKE_BUILD_TYPE=Release \
      -D wxBUILD_TYPE=gtk3 \
      ${MODPKG_BUILD_DIR}

cmake --parallel ${NTHREAD} --build . --target install

# ===================================================
#                       Module File
# ===================================================

# Create Module File
mkdir -p ${MODPKG_MODULE_DIR}
cat << EOF > ${MODPKG_MODULE_DIR}/${PKG_VERSION}.lua

help([[ ${PKG} version ${PKG_VERSION} ]])
family("wxwidgets")

-- Conflicting modules

-- Dependencies
prereq("${COMPILER}/${COMPILER_VERSION}")

-- Modulepath for packages built with this library

-- Environment Variables
local base = "${MODPKG_INSTALL_DIR}"

setenv("WXWIDGETS_ROOT", base)

-- Environment Paths
prepend_path("LIBRARY_PATH",    pathJoin(base, "lib64"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base, "lib64"))
EOF
