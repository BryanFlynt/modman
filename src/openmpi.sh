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
export PKG=openmpi
export PKG_VERSION=$1
export COMPILER=$2
export COMPILER_VERSION=$3

# Load build environment
module purge
module load ${COMPILER}/${COMPILER_VERSION}
module load hwloc

# ----------------------------------------------------------------------
#                          Make Directories
# ----------------------------------------------------------------------

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}/${COMPILER}/${COMPILER_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}/${COMPILER}/${COMPILER_VERSION}

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# Make the build directory and cd into it
mkdir -p ${LIB_BUILD_DIR}
cd ${LIB_BUILD_DIR}

# ----------------------------------------------------------------------
#                        Download (if Needed)
# ----------------------------------------------------------------------

LOCAL_DOWNLOAD_NAME=${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.bz2

VERSION_SPLIT=(${PKG_VERSION//./ })
OMP_VERSION="v${VERSION_SPLIT[0]}.${VERSION_SPLIT[1]}"
REMOTE_DOWNLOAD_NAME="https://download.open-mpi.org/release/open-mpi/${OMP_VERSION}/openmpi-${PKG_VERSION}.tar.bz2"

if [[ ! -f "${LOCAL_DOWNLOAD_NAME}" ]]; then
    ${DOWNLOAD_CMD} ${LOCAL_DOWNLOAD_NAME} ${REMOTE_DOWNLOAD_NAME}
fi

# ----------------------------------------------------------------------
#                            UnPack + Patch
# ----------------------------------------------------------------------

# Unpack the Source
tar --strip-components 1 -xvf ${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.*

# Configure (Detecting if SLURM is installed)
./configure --prefix=${LIB_INSTALL_DIR}               \
            --enable-mpi-cxx                          \
            --enable-cxx-exceptions                   \
            --enable-mpi-fortran=usempi               \
	    --with-hwloc=${HWLOC_ROOT}                \
            --without-verbs


# ----------------------------------------------------------------------
#                            Build + Install
# ----------------------------------------------------------------------

make -j
make install

# ----------------------------------------------------------------------
#                            Create Module File
# ----------------------------------------------------------------------

# Create Module File
mkdir -p ${MODULE_DIR}/compiler/${COMPILER}/${COMPILER_VERSION}/${PKG}
cat << EOF > ${MODULE_DIR}/compiler/${COMPILER}/${COMPILER_VERSION}/${PKG}/${PKG_VERSION}.lua

help([[ ${PKG} version ${PKG_VERSION} ]])
family("mpi")

-- Conflicts

-- Dependencies
prereq("${COMPILER}/${COMPILER_VERSION}")

-- Modulepath for packages built by this compiler
prepend_path("MODULEPATH", "${MODULE_DIR}/mpi/${PKG}/${PKG_VERSION}/${COMPILER}/${COMPILER_VERSION}")

-- Environment Paths
prepend_path("PATH",              "${LIB_INSTALL_DIR}/bin")
prepend_path("CPATH",             "${LIB_INSTALL_DIR}/include")
prepend_path("DYLD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib")

-- Environment Variables
setenv("MPI_ROOT",  "${LIB_INSTALL_DIR}")
setenv("MPI_HOME",  "${LIB_INSTALL_DIR}")

-- Should be then re-set serial vars ???
setenv("CC",  "${LIB_INSTALL_DIR}/bin/mpicc")
setenv("CXX", "${LIB_INSTALL_DIR}/bin/mpicxx")
setenv("FC",  "${LIB_INSTALL_DIR}/bin/mpifort")
EOF
