#!/bin/bash -l

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# Set the package name
export PKG=netcdf
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
module load hdf5

# Make full path names to locations
LIB_BUILD_DIR=$(readlink -m ${BUILD_DIR}/${PKG}/${PKG_VERSION}/${MPI_COMPILER}/${MPI_COMPILER_VERSION}/${COMPILER}/${COMPILER_VERSION})
LIB_INSTALL_DIR=$(readlink -m ${INSTALL_DIR}/${PKG}/${PKG_VERSION}/${MPI_COMPILER}/${MPI_COMPILER_VERSION}/${COMPILER}/${COMPILER_VERSION})

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# Make the build directory (C, C++, Fortran) and cd into it
mkdir -p ${LIB_BUILD_DIR}
mkdir -p ${LIB_BUILD_DIR}/c
mkdir -p ${LIB_BUILD_DIR}/cxx
mkdir -p ${LIB_BUILD_DIR}/f
cd ${LIB_BUILD_DIR}

#
# -------------------------------------------------------------------
# NetCDF-C Library
# ------------------------------------------------------------------
#
cd ${LIB_BUILD_DIR}/c

# Unpack the Source
tar --strip-components 1 -xvf ${TAR_DIR}/${PKG}-c-${PKG_VERSION}.tar.gz

# Configure
if [ ! -z "${MPI_COMPILER}" ]; then
    ./configure --prefix=${LIB_INSTALL_DIR} --enable-parallel --enable-cxx-4 --enable-netcdf-4
else
    ./configure --prefix=${LIB_INSTALL_DIR} --enable-cxx-4 --enable-netcdf-4
fi

# Build it
make -j `nproc`
make check
make install

export CPATH=${LIB_INSTALL_DIR}/include:${CPATH}
export LIBRARY_PATH=${LIB_INSTALL_DIR}/lib:${LIBRARY_PATH}
export LD_LIBRARY_PATH=${LIB_INSTALL_DIR}/lib:${LD_LIBRARY_PATH}
export LIBRARY_PATH=${LIB_INSTALL_DIR}/lib64:${LIBRARY_PATH}
export LD_LIBRARY_PATH=${LIB_INSTALL_DIR}/lib64:${LD_LIBRARY_PATH}



#
# -------------------------------------------------------------------
# NetCDF-C++ Library
# ------------------------------------------------------------------
#
cd ${LIB_BUILD_DIR}/cxx

# Unpack the Source
tar --strip-components 1 -xvf ${TAR_DIR}/${PKG}-cxx-${PKG_VERSION}.tar.gz

# Configure
if [ ! -z "${MPI_COMPILER}" ]; then
    ./configure --prefix=${LIB_INSTALL_DIR} --enable-parallel
else
    ./configure --prefix=${LIB_INSTALL_DIR}
fi

# Build it
make -j `nproc`
make check
make install

#
# -------------------------------------------------------------------
# NetCDF-F Library
# ------------------------------------------------------------------
#
cd ${LIB_BUILD_DIR}/f

# Unpack the Source
tar --strip-components 1 -xvf ${TAR_DIR}/${PKG}-f-${PKG_VERSION}.tar.gz

# Configure
if [ ! -z "${MPI_COMPILER}" ]; then
    ./configure --prefix=${LIB_INSTALL_DIR} --enable-parallel
else
    ./configure --prefix=${LIB_INSTALL_DIR}
fi

# Build it
make -j `nproc`
#make check
make install

#
# -------------------------------------------------------------------
# Create Module File
# ------------------------------------------------------------------
#

# Create Module File
family=compiler
if [ ! -z "${MPI_COMPILER}" ]; then
    family=mpi
fi
location_of_module=$(readlink -m ${MODULE_DIR}/${family}/${MPI_COMPILER}/${MPI_COMPILER_VERSION}/${COMPILER}/${COMPILER_VERSION}/${PKG})
name_of_module=${location_of_module}/${PKG_VERSION}.lua
mkdir -p ${location_of_module}
cat << EOF > ${name_of_module}
help([[ ${PKG} version ${PKG_VERSION} ]])
family("netcdf")

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
prereq("${HDF5_MODULE_VERSION}")

-- Modulepath for packages built with this library

-- Environment Paths
prepend_path("PATH",            "${LIB_INSTALL_DIR}/bin")
prepend_path("CPATH",           "${LIB_INSTALL_DIR}/include")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib64")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib64")

-- Environment Variables
setenv("NETCDF_DIR",                "${LIB_INSTALL_DIR}")
setenv("NETCDF_ROOT",               "${LIB_INSTALL_DIR}")
setenv("NETCDF_C_MODULE_VERSION",   "${PKG}/${PKG_VERSION}")
setenv("NETCDF_CXX_MODULE_VERSION", "${PKG}/${PKG_VERSION}")
setenv("NETCDF_F_MODULE_VERSION",   "${PKG}/${PKG_VERSION}")
EOF
