#!/bin/bash -l

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# Set the package name
export PKG=sycl
export PKG_VERSION=$1

# Load build environment
module purge
module load cmake
module load cuda
module load anaconda # Needs Python 3

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# Make the build directory and cd into it
mkdir -p ${LIB_BUILD_DIR}
cd ${LIB_BUILD_DIR}

# Untar the tarball
tar --strip-components 1 -xvf ${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.*

# Run the provided buildbot script
python ./buildbot/configure.py --cuda -t release --cmake-gen "Unix Makefiles"

# Builds into it's own "install" directory
cd build
make install -j `nproc`

# Move the "install" to our location
mkdir -p ${LIB_INSTALL_DIR}
mv install/* ${LIB_INSTALL_DIR}/.

# Create Module File
mkdir -p ${MODULE_DIR}/base/${PKG}
cat << EOF > ${MODULE_DIR}/base/${PKG}/${PKG_VERSION}.lua

help([[ ${PKG} version ${PKG_VERSION} ]])
family("compiler")

-- Conflicting modules
conflict("gcc")
conflict("llvm")

-- Modulepath for packages built by this compiler
prepend_path("MODULEPATH", "${MODULE_DIR}/compiler/${PKG}/${PKG_VERSION}")

-- Environment Paths
prepend_path("PATH",            "${LIB_INSTALL_DIR}/bin")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib")
prepend_path("LIBRARY_PATH",    "${LIB_INSTALL_DIR}/lib64")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib")
prepend_path("LD_LIBRARY_PATH", "${LIB_INSTALL_DIR}/lib64")

-- Environment Variables
setenv("CPP", "${LIB_INSTALL_DIR}/bin/clang-cpp")
setenv("CC",  "${LIB_INSTALL_DIR}/bin/clang")
setenv("CXX", "${LIB_INSTALL_DIR}/bin/clang++ -fsycl -fsycl-targets=nvptx64-nvidia-cuda-sycldevice")
EOF
