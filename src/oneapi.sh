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
module load gcc

# Clean if they already exist
#rm -rf ${MODPKG_BUILD_DIR}
#rm -rf ${MODPKG_INSTALL_DIR}

# ===================================================
#                       Download
# ===================================================

# It needs to download the off/on line installer
# - The offline one is > 2GB
# - The online one is  < 20MB

# Intel oneAPI HPC Toolkit Download
if [ "$PKG_VERSION" = "2025.3.1" ]; then
    URL_TARGET="${MODPKG_DOWNLOAD_DIR}/intel-oneapi-hpc-toolkit-2025.3.1.55.sh"
elif [ "$PKG_VERSION" = "2026.1.0" ]; then
    URL_TARGET="${MODPKG_DOWNLOAD_DIR}/intel-oneapi-toolkit-2026.1.0.192.sh"
else
    printf "ERROR: This version of oneAPI is not recognized\n"
    printf "You will need to pre-download the installation script and modify src/oneapi.sh\n"
    exit 1
fi

# Verify Script exists
if [ -f "${URL_TARGET}" ]; then
    printf "Using Installer: ${URL_TARGET}\n"
else
    printf "ERROR: Installation file not Found\n${URL_TARGET}"
    exit 1
fi

# ===================================================
#                  UnPack + Install
# ===================================================

# Create Build Directory
mkdir -p ${MODPKG_BUILD_DIR}
cd ${MODPKG_BUILD_DIR}

# Run the Script (HPC Toolkit)
bash ${URL_TARGET} -a --action=install --install-dir=${MODPKG_INSTALL_DIR} --components=all --eula=accept --intel-sw-improvement-program-consent=decline --silent

# ===================================================
#                       Module File
# ===================================================

# Split version into parts 
IFS='.' read -ra PARTS <<< "${PKG_VERSION}"  # PARTS=("2" "4" "1")

PKG_SUBVER=${PARTS[0]}.${PARTS[1]}

gnu_c_compiler=${CC}
gnu_bin_dir=$(dirname ${CC})
gnu_base_name=$(dirname ${gnu_bin_dir})

mkdir -p ${MODPKG_MODULE_DIR}
cat << EOF > ${MODPKG_MODULE_DIR}/${PKG_VERSION}.lua
help([[ ${PKG} version ${PKG_VERSION} ]])
family("compiler")

-- Conflicting modules
conflict("gcc")
conflict("llvm")

-- Modulepath for packages built by this compiler
prepend_path("MODULEPATH", "${MODMAN_MODULE_DIR}/compiler/${PKG}/${PKG_VERSION}")

-- Installation location
local base = "${MODPKG_INSTALL_DIR}"

-- Point at Latest GCC Compiler
prepend_path("PATH",            "${gnu_base_name}/bin")
prepend_path("LD_LIBRARY_PATH", "${gnu_base_name}/lib")
prepend_path("LD_LIBRARY_PATH", "${gnu_base_name}/lib64")

-- Environment Paths
prepend_path("PATH",            pathJoin(base, "compiler/${PKG_SUBVER}/bin"))
prepend_path("CPATH",           pathJoin(base, "compiler/${PKG_SUBVER}/include"))

prepend_path("LIBRARY_PATH",    pathJoin(base, "compiler/${PKG_SUBVER}/lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base, "compiler/${PKG_SUBVER}/lib"))

-- Environment Variables
setenv("CPP", pathJoin(base, "compiler/${PKG_SUBVER}/bin/icpx -E"))
setenv("CC",  pathJoin(base, "compiler/${PKG_SUBVER}/bin/icx"))
setenv("CXX", pathJoin(base, "compiler/${PKG_SUBVER}/bin/icpx"))
setenv("FPP", pathJoin(base, "compiler/${PKG_SUBVER}/bin/fpp"))
setenv("FC",  pathJoin(base, "compiler/${PKG_SUBVER}/bin/ifx"))
setenv("INTEL_TARGET_ARCH", "intel64")
EOF
