#!/bin/bash -l

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
module load ucx
module load libevent

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}/${COMPILER}/${COMPILER_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}/${COMPILER}/${COMPILER_VERSION}

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# Make the build directory and cd into it
mkdir -p ${LIB_BUILD_DIR}
cd ${LIB_BUILD_DIR}

# Unpack the Source
tar --strip-components 1 -xvf ${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.*

# Configure (Detecting if SLURM is installed)
if ! [ -x "$(command -v sbatch)" ]; then
    ./configure --prefix=${LIB_INSTALL_DIR}               \
                --enable-mpi-cxx                          \
                --enable-cxx-exceptions                   \
                --enable-mpi-fortran=usempi               \
                --with-hwloc=${HWLOC_ROOT}                \
                --with-ucx=${UCX_ROOT}                    \
                --with-libevent=${LIBEVENT_ROOT}          \
                --without-verbs                           \
                -enable-mca-no-build=btl-uct   
else
    slurm_command=$(command -v sbatch)
    pmi_path=${slurm_command%/*/*}
    ./configure --prefix=${LIB_INSTALL_DIR}               \
                --enable-mpi-cxx                          \
                --enable-cxx-exceptions                   \
                --enable-mpi-fortran=usempi               \
                --with-slurm                              \
                --with-pmi=${pmi_path}                    \
                --with-pmi-libdir=${pmi_path}/lib         \
                --with-hwloc=${HWLOC_ROOT}                \
                --with-ucx=${UCX_ROOT}                    \
                --with-libevent=${LIBEVENT_ROOT}          \
                --without-verbs
fi

# Build
make -j 8

# Install
make install

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
prepend_path("PATH",            "${LIB_INSTALL_DIR}/bin")
prepend_path("CPATH",           "${LIB_INSTALL_DIR}/include")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib64")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib64")

-- Environment Variables
setenv("MPI_ROOT",             "${LIB_INSTALL_DIR}")
setenv("MPI_HOME",             "${LIB_INSTALL_DIR}")
setenv("MPI_C_COMPILER",       "${LIB_INSTALL_DIR}/bin/mpicc")
setenv("MPI_CXX_COMPILER",     "${LIB_INSTALL_DIR}/bin/mpicxx")
setenv("MPI_Fortran_COMPILER", "${LIB_INSTALL_DIR}/bin/mpifort")

-- Should be then re-set serial vars ???
setenv("CC",  "${LIB_INSTALL_DIR}/bin/mpicc")
setenv("CXX", "${LIB_INSTALL_DIR}/bin/mpicxx")
setenv("FC",  "${LIB_INSTALL_DIR}/bin/mpifort")
EOF
