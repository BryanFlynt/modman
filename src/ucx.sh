#!/bin/bash -l

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# Set the package name
export PKG=ucx
export PKG_VERSION=$1
export COMPILER=$2
export COMPILER_VERSION=$3

# Load build environment
module purge
module load ${COMPILER}/${COMPILER_VERSION}

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

# PGI has a bug which needs to be patched
if [ "${COMPILER}" == "pgi" ]; then
    if [ "${PKG_VERSION}" == "1.10.1" ]; then
        echo "Patching for GPI"
#        sed -i "14i BASE_CFLAGS=\"-g -Wall\" " ${LIB_BUILD_DIR}/config/m4/compiler.m4
        sed -i "476i [--diag_suppress 1]," ${LIB_BUILD_DIR}/config/m4/compiler.m4
        sed -i "476i [--diag_suppress 68]," ${LIB_BUILD_DIR}/config/m4/compiler.m4
        sed -i "476i [--diag_suppress 111]," ${LIB_BUILD_DIR}/config/m4/compiler.m4
        sed -i "476i [--diag_suppress 167]," ${LIB_BUILD_DIR}/config/m4/compiler.m4
        sed -i "477i [--diag_suppress 188]," ${LIB_BUILD_DIR}/config/m4/compiler.m4
        sed -i "477i [--diag_suppress 1144]," ${LIB_BUILD_DIR}/config/m4/compiler.m4
        autoreconf -i
    fi
fi   

# Configure and Check for NUMA
cat > .test.h <<'EOM'
#include <numa.h>
EOM
if gcc -E .test.h; then
    ./configure --prefix=${LIB_INSTALL_DIR}
else
    ./configure --prefix=${LIB_INSTALL_DIR} --disable-numa
fi

make -j 8
make check
make install

# Create Module File
mkdir -p ${MODULE_DIR}/compiler/${COMPILER}/${COMPILER_VERSION}/${PKG}
cat << EOF > ${MODULE_DIR}/compiler/${COMPILER}/${COMPILER_VERSION}/${PKG}/${PKG_VERSION}.lua
help([[ ${PKG} version ${PKG_VERSION} ]])
family("ucx")

-- Conflicts

-- Dependencies
prereq("${COMPILER}/${COMPILER_VERSION}")

-- Modulepath for packages built with this library

-- Environment Paths
prepend_path("PATH",            "${LIB_INSTALL_DIR}/bin")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib64")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib64")

-- Environment Variables
setenv("UCX_ROOT",              "${LIB_INSTALL_DIR}")
EOF
