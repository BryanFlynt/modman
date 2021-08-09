#!/bin/bash -l

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# Set the package name
export PKG=nvhpc
export PKG_VERSION=$1

# Load build environment
module purge
module load gcc
module load cuda

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# Make the build directory and cd into it
mkdir -p ${LIB_BUILD_DIR}
cd ${LIB_BUILD_DIR}

# Unpack the source download
tar --strip-components 1 -xvf ${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.*

# Set environment variable controlling install
export NVHPC_SILENT="true"
export NVHPC_ACCEPT_EULA="accept"
export NVHPC_INSTALL_DIR=${LIB_INSTALL_DIR}
export NVHPC_INSTALL_TYPE="single"
#export NVHPC_INSTALL_LOCAL_DIR=(required for network install) Set this variable to a string containing the path to a local file system when choosing a network install.
export NVHPC_INSTALL_NVIDIA="false"
export NVHPC_INSTALL_MPI="false"
export NVHPC_MPI_GPU_SUPPORT="false"

# Run the install script
./install

# Place a "siterc" file for system to operate with GCC
cat << EOF > ${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/bin/siterc
set PREOPTIONS=-D__GCC_ATOMIC_TEST_AND_SET_TRUEVAL=1;
EOF


mkdir -p ${MODULE_DIR}/base/${PKG}
cat << EOF > ${MODULE_DIR}/base/${PKG}/${PKG_VERSION}.lua
help([[ ${PKG} version ${PKG_VERSION} ]])
family("compiler")

-- Conflicting modules
conflict("gcc")
conflict("llvm")
conflict("oneapi")
conflict("nvptx")
conflict("pgi")

-- Modulepath for NVHPC Compiler
prepend_path("MODULEPATH", "${MODULE_DIR}/compiler/${PKG}/${PKG_VERSION}")

-- Temporary Variables (can use within file only)
local nvhpc_home = pathJoin(${LIB_INSTALL_DIR},"Linux_x86_64",${PKG_VERSION})
local nvhpc_math = pathJoin($nvhpc_home,"math_libs")
local nvhpc_comp = pathJoin($nvhpc_home,"compilers")
local nvhpc_comm = pathJoin($nvhpc_home,"comm_libs")

-- Environment Paths
prepend_path("PATH",            "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/cuda/bin")
prepend_path("PATH",            "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/bin")
prepend_path("PATH",            "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/comm_libs/mpi/bin")

prepend_path("CPATH",           "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/math_libs/include")
prepend_path("CPATH",           "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/comm_libs/mpi/include")
prepend_path("CPATH",           "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/comm_libs/nccl/include")
prepend_path("CPATH",           "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/comm_libs/nvshmem/include")

prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/cuda/lib64")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/cuda/extras/CUPTI/lib64")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/lib")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/math_libs/lib64")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/comm_libs/mpi/lib")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/comm_libs/nccl/lib")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/comm_libs/nvshmem/lib")

prepend_path("MANPATH",         "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/man")

-- Environment Variables
setenv("NVHPC",       "${LIB_INSTALL_DIR}")
setenv("CPP",         "cpp")
setenv("CC",          "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/bin/nvc")
setenv("CXX",         "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/bin/nvc++")
setenv("FPP",         "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/bin/nvfortran")
setenv("FC",          "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/bin/nvfortran")
setenv("F90",         "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/bin/nvfortran")
setenv("F77",         "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/bin/nvfortran") 
setenv("OPAL_PREFIX", "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/comm_libs/mpi")
EOF
