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
if [ ! -z "${MPI_COMPILER}" ]; then
    module load ${MPI_COMPILER}/${MPI_COMPILER_VERSION}
fi

# Clean if they already exist
rm -rf ${MODPKG_BUILD_DIR}
rm -rf ${MODPKG_INSTALL_DIR}

# ===================================================
#                       Download
# ===================================================

# Split version into parts 
IFS='.' read -ra PARTS <<< "${PKG_VERSION}"  # PARTS=("2" "4" "1")

URL_ROOT="https://archives.boost.io/release"
URL_DIR="${PKG_VERSION}/source"
URL_NAME="${PKG}_${PARTS[0]}_${PARTS[1]}_${PARTS[2]}"
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
tar --strip-components 1 -xvf ${URL_TARGET}

# ===================================================
#           Bootstrap + Patch + Build + Install
# ===================================================

# Do an out of source build by making a temporary build directory
#mkdir -p ${MODPKG_BUILD_DIR}/build_by_modman
cd ${MODPKG_BUILD_DIR}

# Build the boot strap builder
toolname=none
case ${COMPILER} in
    "gcc" )
        toolname=gcc
        ;;
    "nvptx" )
        toolname=gcc
        ;;
    "intel" )
        toolname=intel-linux
        ;;
    "oneapi" )
        toolname=intel-linux
        ;;
    "pgi" )
        toolname=pgi
        ;;
    "llvm" )
        toolname=clang
        ;;
    *)
        echo "Unsupported compiler: ${COMPILER}"
        exit 1
        ;;
esac

# Create the booststrap file
./bootstrap.sh --prefix=${MODPKG_INSTALL_DIR}
#./bootstrap.sh --show-libraries

# Replace the language about the system compiler with our toolname
# - Only needed if we build bootstrap with gcc then src with another
# - i.e. Replace gcc with intel-linux
#sed -i "s/gcc/${toolname}/g" project-config.jam

# Insert specifics about the MPI compiler
# Note: The space before and after : and before ; are required
if [ ! -z "${MPI_COMPILER}" ]; then
    printf "\n# MPI Compiler Details\n"               >> project-config.jam
    printf "using mpi : %s ;\n" "${MPI_CXX_COMPILER}" >> project-config.jam
fi

./b2 -j8 install

# ===================================================
#                       Module File
# ===================================================

# Create Module File
mkdir -p ${MODPKG_MODULE_DIR}
cat << EOF > ${MODPKG_MODULE_DIR}/${PKG_VERSION}.lua
help([[ ${PKG} version ${PKG_VERSION} ]])
family("boost")

-- Conflicts

-- Dependencies
prereq("${COMPILER}/${COMPILER_VERSION}")
EOF

if [ ! -z "${MPI_COMPILER}" ]; then
cat << EOF >> ${MODPKG_MODULE_DIR}/${PKG_VERSION}.lua
prereq("${MPI_COMPILER}/${MPI_COMPILER_VERSION}")
EOF
fi

cat << EOF >> ${MODPKG_MODULE_DIR}/${PKG_VERSION}.lua

-- Modulepath for packages built with this library

-- Environment Variables
local base = "${MODPKG_INSTALL_DIR}"

setenv("BOOST_ROOT",            base)

-- Environment Paths
prepend_path("CPATH",           pathJoin(base, "include")
prepend_path("LIBRARY_PATH",    pathJoin(base, "lib64"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base, "lib64"))
EOF

