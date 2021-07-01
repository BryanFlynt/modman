#!/bin/bash -l

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# Set the package name
export PKG=oneapi
export PKG_VERSION=$1

# Load build environment
module purge
module load gcc

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# Make the build directory and cd into it
mkdir -p ${LIB_BUILD_DIR}
cd ${LIB_BUILD_DIR}

# Run the Script (Base ToolKit)
bash ${TAR_DIR}/${PKG}_base-${PKG_VERSION}.sh -a --action=install --install-dir=${LIB_INSTALL_DIR} --components=all --eula=accept --intel-sw-improvement-program-consent=decline --silent

# Run the Script (HPC Toolkit)
bash ${TAR_DIR}/${PKG}_hpc-${PKG_VERSION}.sh -a --action=install --install-dir=${LIB_INSTALL_DIR} --components=all --eula=accept --intel-sw-improvement-program-consent=decline --silent

# Advisor Module
mkdir -p ${MODULE_DIR}/base/advisor
cat << EOF > ${MODULE_DIR}/base/advisor/${PKG_VERSION}.lua
help([[ Intel Advisor version ${PKG_VERSION} ]])
family("advisor")

-- Conflicting modules

-- Modulepath for packages built by this compiler

-- Environment Paths
prepend_path("PATH",        "${LIB_INSTALL_DIR}/advisor/${PKG_VERSION}/bin64")
prepend_path("PYTHONPATH",  "${LIB_INSTALL_DIR}/advisor/${PKG_VERSION}/pythonapi")

-- Environment Variables
setenv("ADVISOR_2021_DIR",  "${LIB_INSTALL_DIR}/advisor/${PKG_VERSION}")
setenv("APM",               "${LIB_INSTALL_DIR}/advisor/${PKG_VERSION}/perfmodels")
EOF

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

-- Modulepath for packages built by this compiler
prepend_path("MODULEPATH", "${MODULE_DIR}/compiler/${PKG}/${PKG_VERSION}")

-- Point at Latest GCC Compiler
prepend_path("PATH",            "${gnu_base_name}/bin")
prepend_path("LD_LIBRARY_PATH", "${gnu_base_name}/lib")
prepend_path("LD_LIBRARY_PATH", "${gnu_base_name}/lib64")

-- Environment Paths
prepend_path("PATH",            "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/bin/intel64")
prepend_path("PATH",            "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/bin")
prepend_path("CPATH",           "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/include")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/lib")

prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/lib")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/lib/emu")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/lib/x64")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/compiler/${PKG_VERSION}/linux/compiler/lib/intel64_lin")

prepend_path("OCL_ICD_FILENAMES", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/lib/x64/libintelocl.so")
prepend_path("MANPATH",           "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/documentation/en/man/common")

-- Environment Variables
setenv("CPP", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/bin/icpx")
setenv("CC",  "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/bin/icx")
setenv("CXX", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/bin/icpx")
setenv("FPP", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/bin/fpp")
setenv("FC",  "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/bin/ifx")
setenv("INTEL_TARGET_ARCH", "intel64")
EOF

# MPI Module
mkdir -p ${MODULE_DIR}/compiler/${PKG}/${PKG_VERSION}/impi
cat << EOF > ${MODULE_DIR}/compiler/${PKG}/${PKG_VERSION}/impi/${PKG_VERSION}.lua
help([[ Intel MPI ${PKG} version ${PKG_VERSION} ]])
family("mpi")

-- Dependencies
prereq_any("${PKG}/${PKG_VERSION}")

prepend_path("PATH",            "${LIB_INSTALL_DIR}/mpi/${PKG_VERSION}/bin")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/mpi/${PKG_VERSION}/lib")

-- SetUp Intel Variables
setenv("I_MPI_ROOT", "${LIB_INSTALL_DIR}/mpi/${PKG_VERSION}")
if os.getenv("CC") then
    setenv("I_MPI_CC", os.getenv("CC"))
end
if os.getenv("CXX") then
    setenv("I_MPI_CXX", os.getenv("CXX"))
end
if os.getenv("FC") then
    setenv("I_MPI_FC", os.getenv("FC"))
end

-- Setup environment variables
setenv("MPI_ROOT",             "${LIB_INSTALL_DIR}/mpi/${PKG_VERSION}")
setenv("MPI_C_COMPILER",       "${LIB_INSTALL_DIR}/mpi/${PKG_VERSION}/bin/mpiicc")
setenv("MPI_CXX_COMPILER",     "${LIB_INSTALL_DIR}/mpi/${PKG_VERSION}/bin/mpiicpc")
setenv("MPI_Fortran_COMPILER", "${LIB_INSTALL_DIR}/mpi/${PKG_VERSION}/bin/mpiifort")

-- Should be then re-set serial vars ???
setenv("CC",  "${LIB_INSTALL_DIR}/mpi/${PKG_VERSION}/bin/mpiicc")
setenv("CXX", "${LIB_INSTALL_DIR}/mpi/${PKG_VERSION}/bin/mpiicpc")
setenv("FC",  "${LIB_INSTALL_DIR}/mpi/${PKG_VERSION}/bin/mpiifort")
EOF

# MKL Module
mkdir -p ${MODULE_DIR}/base/mkl
cat << EOF > ${MODULE_DIR}/base/mkl/${PKG_VERSION}.lua
help([[ MKL version ${PKG_VERSION} ]])
family("blas")

-- Conflicting modules

-- Modulepath for packages built by this compiler

-- Environment Paths
prepend_path("PATH",            "${LIB_INSTALL_DIR}/mkl/${PKG_VERSION}/bin/intel64")
prepend_path("CPATH",           "${LIB_INSTALL_DIR}/mkl/${PKG_VERSION}/include")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/mkl/${PKG_VERSION}/lib/intel64")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/mkl/${PKG_VERSION}/lib/intel64")

prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/compiler/lib/intel64_lin")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/compiler/lib/intel64_lin")
EOF
