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
module load ${COMPILER}/${COMPILER_VERSION}
module load hwloc
module load ucx
module load libevent

# Clean if they already exist
rm -rf ${MODPKG_BUILD_DIR}
rm -rf ${MODPKG_INSTALL_DIR}

# ===================================================
#                       Download
# ===================================================

# Split version into parts 
IFS='.' read -ra PARTS <<< "${PKG_VERSION}"  # PARTS=("2" "4" "1")

URL_ROOT="https://download.open-mpi.org/release/open-mpi"
URL_DIR="v${PARTS[0]}.${PARTS[1]}"
URL_NAME="${PKG}-${PKG_VERSION}"
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
#                         Build
# ===================================================

# Do an out of source build by making a temporary build directory
mkdir -p ${MODPKG_BUILD_DIR}/build_by_modman
cd ${MODPKG_BUILD_DIR}/build_by_modman

# Configure   --enable-mpi-fortran=usempif08
if ! [ -x "$(command -v sbatch)" ]; then
    ${MODPKG_BUILD_DIR}/configure --prefix=${MODPKG_INSTALL_DIR} \
                       --enable-mpi-fortran=usempif08            \
                       --enable-mca-no-build=btl-uct             \
                       --with-hwloc=${HWLOC_ROOT}                \
                       --with-ucx=${UCX_ROOT}                    \
                       --with-libevent=${LIBEVENT_ROOT}          \
                       --without-verbs
else
    slurm_command=$(command -v sbatch)
    pmi_path=${slurm_command%/*/*}
    ${MODPKG_BUILD_DIR}/configure --prefix=${MODPKG_INSTALL_DIR} \
                       --enable-mpi-fortran=usempif08            \
                       --enable-mca-no-build=btl-uct             \
                       --with-slurm                              \
                       --with-pmi=${pmi_path}                    \
                       --with-pmi-libdir=${pmi_path}/lib         \
                       --with-hwloc=${HWLOC_ROOT}                \
                       --with-ucx=${UCX_ROOT}                    \
                       --with-libevent=${LIBEVENT_ROOT}          \
                       --without-verbs
fi

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
family("mpi")

-- Conflicts

-- Dependencies
prereq("${COMPILER}/${COMPILER_VERSION}")

-- Modulepath for packages built by this compiler
prepend_path("MODULEPATH", "${MODULE_DIR}/mpi/${PKG}/${PKG_VERSION}/${COMPILER}/${COMPILER_VERSION}")

-- Environment Variables
local base = "${MODPKG_INSTALL_DIR}"

setenv("MPI_ROOT",             base)
setenv("MPI_HOME",             base)
setenv("MPI_C_COMPILER",       pathJoin(base, "bin/mpicc"))
setenv("MPI_CXX_COMPILER",     pathJoin(base, "bin/mpicxx"))
setenv("MPI_Fortran_COMPILER", pathJoin(base, "bin/mpifort"))

-- Environment Paths
prepend_path("PATH",            pathJoin(base, "bin"))
prepend_path("CPATH",           pathJoin(base, "include"))
prepend_path("LIBRARY_PATH",    pathJoin(base, "lib64"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base, "lib64"))

-- Should be then re-set serial vars ???
setenv("CC",  pathJoin(base, "bin/mpicc"))
setenv("CXX", pathJoin(base, "bin/mpicxx"))
setenv("FC",  pathJoin(base, "bin/mpifort"))
EOF
