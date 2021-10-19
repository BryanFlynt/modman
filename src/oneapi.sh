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

# ------------------------------------------------------
# Advisor Module
# ------------------------------------------------------
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

# ------------------------------------------------------
# Compiler Module
# ------------------------------------------------------
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
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/lib/emu")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/lib/x64")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/compiler/lib/intel64_lin")

prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/lib")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/lib/emu")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/lib/x64")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/compiler/lib/intel64_lin")

prepend_path("OCL_ICD_FILENAMES", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/lib/x64/libintelocl.so")
prepend_path("MANPATH",           "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/documentation/en/man/common")

-- Environment Variables
setenv("CPP", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/bin/icpx -E")
setenv("CC",  "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/bin/icx")
setenv("CXX", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/bin/icpx")
setenv("FPP", "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/bin/fpp")
setenv("FC",  "${LIB_INSTALL_DIR}/compiler/${PKG_VERSION}/linux/bin/ifx")
setenv("INTEL_TARGET_ARCH", "intel64")
EOF

# ------------------------------------------------------
# MPI Module
# ------------------------------------------------------
impi_install_dir=${LIB_INSTALL_DIR}/mpi/${PKG_VERSION}             # Location of IMPI
impi_module_dir=${MODULE_DIR}/compiler/${PKG}/${PKG_VERSION}/impi  # Module lua dir (full path)
impi_module_file=${impi_module_dir}/${PKG_VERSION}.lua             # Module lua file (full path) 
mkdir -p ${impi_module_dir}
cat << EOF > ${impi_module_file}
help([[ Intel MPI ${PKG} version ${PKG_VERSION} ]])
family("mpi")

-- Dependencies
prereq_any("${PKG}/${PKG_VERSION}")

-- Modulepath for packages built by this compiler
prepend_path("MODULEPATH", "${MODULE_DIR}/mpi/impi/${PKG_VERSION}/${PKG}/${PKG_VERSION}")

-- Environment Paths
prepend_path("PATH",            "${impi_install_dir}/bin")
prepend_path("LIBRARY_PATH",    "${impi_install_dir}/lib")
prepend_path("LIBRARY_PATH",    "${impi_install_dir}/lib/release")
prepend_path("LD_LIBRARY_PATH", "${impi_install_dir}/lib")
prepend_path("LD_LIBRARY_PATH", "${impi_install_dir}/lib/release")
prepend_path("CLASSPATH",       "${impi_install_dir}/lib/mpi.jar")

-- SetUp Intel Variables
setenv("I_MPI_ROOT", "${impi_install_dir}")
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
setenv("MPI_ROOT",             "${impi_install_dir}")
setenv("MPI_C_COMPILER",       "${impi_install_dir}/bin/mpiicc")
setenv("MPI_CXX_COMPILER",     "${impi_install_dir}/bin/mpiicpc")
setenv("MPI_Fortran_COMPILER", "${impi_install_dir}/bin/mpiifort")

-- Should be then re-set serial vars ???
setenv("CC",  "${impi_install_dir}/bin/mpiicc")
setenv("CXX", "${impi_install_dir}/bin/mpiicpc")
setenv("FC",  "${impi_install_dir}/bin/mpiifort")

EOF
if [ -d "${impi_install_dir}/libfabric" ]; then
cat << EOF >> ${impi_module_file}
-- IB Fabric Variables for IMPI
prepend_path("PATH",            "${impi_install_dir}/libfabric/bin")
prepend_path("LIBRARY_PATH",    "${impi_install_dir}/libfabric/lib")
prepend_path("LD_LIBRARY_PATH", "${impi_install_dir}/libfabric/lib")
setenv("FI_PROVIDER",           "mlx")
setenv("FI_PROVIDER_PATH",      "${impi_install_dir}/libfabric/lib/prov")

EOF
fi
if [ -x "$(command -v sbatch)" ]; then
slurm_command=$(command -v sbatch)
pmi_path=${slurm_command%/*/*}
if [ -f "${pmi_path}/lib/libpmi.so" ]; then
cat << EOF >> ${impi_module_file}
-- Slurm Environment for IMPI
setenv("I_MPI_PMI_LIBRARY", "${pmi_path}/lib/libpmi.so")
EOF
fi
fi

# ------------------------------------------------------
# MKL Module
# ------------------------------------------------------
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

# ------------------------------------------------------
# VTune Module
# ------------------------------------------------------

# VTune version is different that OneAPI Version (Seriously!!!)
if [ ${PKG_VERSION} == "2021.3.0" ]; then
    VTUNE_VERSION=2021.5.0
else
    VTUNE_VERSION=${PKG_VERSION}
fi

mkdir -p ${MODULE_DIR}/base/vtune
cat << EOF > ${MODULE_DIR}/base/vtune/${VTUNE_VERSION}.lua
help([[ Intel VTune version ${VTUNE_VERSION} ]])
family("vtune")

-- Conflicting modules

-- Modulepath for packages built by this compiler

-- Environment Paths
prepend_path("PATH",        "${LIB_INSTALL_DIR}/vtune/${VTUNE_VERSION}/bin64")

-- Environment Variables
setenv("VTUNE_PROFILER_2021_DIR", "${LIB_INSTALL_DIR}/vtune/${VTUNE_VERSION}")
setenv("INTEL_LIBITTNOTIFY64",    "${LIB_INSTALL_DIR}/vtune/${VTUNE_VERSION}/lib64/runtime/libittnotify_collector.so")
prepend_path("PKG_CONFIG_PATH",   "${LIB_INSTALL_DIR}/vtune/${VTUNE_VERSION}/include/pkgconfig/lib64")


-- VTune Instrumentation & Tracing API
prepend_path("CPATH",           "${LIB_INSTALL_DIR}/vtune/2021.5.0/sdk/include") 
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/vtune/2021.5.0/sdk/include")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/vtune/2021.5.0/sdk/include")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/vtune/2021.5.0/sdk/lib64")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/vtune/2021.5.0/sdk/lib64")
EOF
