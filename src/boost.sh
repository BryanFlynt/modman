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
export PKG=boost
export PKG_VERSION=$1
export COMPILER=$2
export COMPILER_VERSION=$3
export MPI_COMPILER=$4
export MPI_COMPILER_VERSION=$5

# Load build environment
module purge
module load ${COMPILER}/${COMPILER_VERSION}
if [ ! -z "${MPI_COMPILER}" ]; then
    module load ${MPI_COMPILER}/${MPI_COMPILER_VERSION}
fi

# ----------------------------------------------------------------------
#                          Make Directories
# ----------------------------------------------------------------------

# Make full path names to locations
LIB_BUILD_DIR=$(readlink -m ${BUILD_DIR}/${PKG}/${PKG_VERSION}/${MPI_COMPILER}/${MPI_COMPILER_VERSION}/${COMPILER}/${COMPILER_VERSION})
LIB_INSTALL_DIR=$(readlink -m ${INSTALL_DIR}/${PKG}/${PKG_VERSION}/${MPI_COMPILER}/${MPI_COMPILER_VERSION}/${COMPILER}/${COMPILER_VERSION})

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

BOOST_VERSION="${PKG_VERSION//./_}"
REMOTE_DOWNLOAD_NAME="https://boostorg.jfrog.io/artifactory/main/release/${PKG_VERSION}/source/boost_${BOOST_VERSION}.tar.bz2"

if [[ ! -f "${LOCAL_DOWNLOAD_NAME}" ]]; then
    ${DOWNLOAD_CMD} ${LOCAL_DOWNLOAD_NAME} ${REMOTE_DOWNLOAD_NAME}
fi

# ----------------------------------------------------------------------
#                            UnPack + Patch
# ----------------------------------------------------------------------

# Unpack the Source
tar --strip-components 1 -xjvf ${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.bz2

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

# The B2 Engine can be built with any compiler supporting C++11
# - So use the system compiler
./bootstrap.sh --prefix=${LIB_INSTALL_DIR}
#./bootstrap.sh --show-libraries

#
# Replace the language about the system compiler with our toolname
# - Replace gcc (ie. with intel-linux)
#
sed -i "s/gcc/${toolname}/g" project-config.jam
#sed -i "0,/gcc/s/gcc/${toolname}/" project-config.jam
#sed -i "0,/gcc/s/gcc/${toolname}/" project-config.jam

#
# Insert specifics about the MPI compiler
# Note: The space before and after : and before ; are required
#
if [ ! -z "${MPI_COMPILER}" ]; then
    printf "\n# MPI Compiler Details\n"               >> project-config.jam
    printf "using mpi : %s ;\n" "${MPI_CXX_COMPILER}" >> project-config.jam
fi

# ----------------------------------------------------------------------
#                            Build + Install
# ----------------------------------------------------------------------

# Compile Boost (turn off/on abort since it never compiles everything)
set +e
./b2 -j ${MODMAN_NPROC} install toolset=${toolname} variant=release --layout=system --target=shared,static
set -e

# ----------------------------------------------------------------------
#                            Create Module File
# ----------------------------------------------------------------------

# Create the module path and filename
family=compiler
if [ ! -z "${MPI_COMPILER}" ]; then
    family=mpi
fi
location_of_module=$(readlink -m ${MODULE_DIR}/${family}/${MPI_COMPILER}/${MPI_COMPILER_VERSION}/${COMPILER}/${COMPILER_VERSION}/${PKG})
name_of_module=${location_of_module}/${PKG_VERSION}.lua

# Create Module File
mkdir -p ${location_of_module}
cat << EOF > ${name_of_module}
help([[ ${PKG} version ${PKG_VERSION} ]])
family("boost")

-- Conflicts

-- Dependencies
prereq("${COMPILER}/${COMPILER_VERSION}")
EOF

if [ ! -z "${MPI_COMPILER}" ]; then
cat << EOF >> ${name_of_module}
prereq("${MPI_COMPILER}/${MPI_COMPILER_VERSION}")
EOF
fi

cat << EOF >> ${name_of_module}

-- Modulepath for packages built with this library

-- Environment Paths
prepend_path("CPATH",           "${LIB_INSTALL_DIR}/include")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib64")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib64")

-- Environment Variables
setenv("BOOST_ROOT",           "${LIB_INSTALL_DIR}")
EOF
