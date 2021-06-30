#!/bin/bash -l

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# Set the package name
export PKG=pgi
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

# Compiler Module
gnu_c_compiler=${CC}
gnu_bin_dir=$(dirname ${CC})
gnu_base_name=$(dirname ${gnu_bin_dir})

mkdir -p ${MODULE_DIR}/base/${PKG}
cat << EOF > ${MODULE_DIR}/base/${PKG}/${PKG_VERSION}.lua
help([[ ${PKG} version ${PKG_VERSION} ]])
family("compiler")

-- Conflicting modules
conflict("gcc")
conflict("llvm")
conflict("oneapi")

-- Modulepath for packages built by this compiler
prepend_path("MODULEPATH", "${MODULE_DIR}/compiler/${PKG}/${PKG_VERSION}")

-- Point at Latest Compiler
prepend_path("PATH",               "${gnu_base_name}/bin")
prepend_path("LIBRARY_PATH",       "${gnu_base_name}/lib")
prepend_path("LIBRARY_PATH",       "${gnu_base_name}/lib64")
prepend_path("LD_LIBRARY_PATH",    "${gnu_base_name}/lib")
prepend_path("LD_LIBRARY_PATH",    "${gnu_base_name}/lib64")
prepend_path("CPLUS_INCLUDE_PATH", "${gnu_base_name}/include")


-- Environment Paths
prepend_path("PATH",            "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/bin")
prepend_path("CPATH",           "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/include")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/lib")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/lib")
prepend_path("MANPATH",         "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/man")

-- Environment Variables
setenv("PGI", "${LIB_INSTALL_DIR}")
setenv("CPP", "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/bin/pgcc -Mcpp")
setenv("CC",  "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/bin/pgcc")
setenv("CXX", "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/bin/pgc++")
setenv("FPP", "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/bin/pgfortran")
setenv("FC",  "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/bin/pgfortran")
setenv("F90", "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/bin/pgf90")
setenv("F77", "${LIB_INSTALL_DIR}/Linux_x86_64/${PKG_VERSION}/compilers/bin/pgf77") 

EOF

