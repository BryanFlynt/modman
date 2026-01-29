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

# Clean if they already exist
rm -rf ${MODPKG_BUILD_DIR}
rm -rf ${MODPKG_INSTALL_DIR}

# ===================================================
#                       Download
# ===================================================

# The path is redirected plus contains Python version and other information
# Therefore, the user should just downloaded the tar.gz and place in downloads directory.

if [ ${PKG_VERSION} = "6.0.1" ]; then
    URL_TARGET="${MODPKG_DOWNLOAD_DIR}/ParaView-6.0.1-MPI-Linux-Python3.12-x86_64.tar.gz"
else
    printf "ERROR: Version not recognized\n"
    exit 1
fi


# If the URL_TARGET is not already downloaded error
if [ ! -f "${URL_TARGET}" ]; then
    printf "ERROR: Paraview *.tar.gz not found in download directory\n"
    printf "Please place the requested version within: %s\n" ${MODPKG_DOWNLOAD_DIR}
    exit 1
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

# Create installation directory
mkdir -p ${MODPKG_INSTALL_DIR}

# Move Unpacked into installation directory
mv ${MODPKG_BUILD_DIR}/* ${MODPKG_INSTALL_DIR}/.

# ===================================================
#                       Module File
# ===================================================

# Create Module File
mkdir -p ${MODPKG_MODULE_DIR}
cat << EOF > ${MODPKG_MODULE_DIR}/${PKG_VERSION}.lua
help([[ ${PKG} version ${PKG_VERSION} ]])
family("${PKG}")

-- Conflicts

-- Dependencies

-- Modulepath for packages built with this library

-- Environment Variables
local base = "${MODPKG_INSTALL_DIR}"

setenv("PARAVIEW_ROOT", base)

-- Environment Paths
prepend_path("PATH", pathJoin(base, "bin"))
EOF
