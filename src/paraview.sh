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

# Set the variables
export PKG=paraview
export PKG_VERSION=$1
export COMPILER=$3
export COMPILER_VERSION=$4
export MPI=$5
export MPI_VERSION=$6

# ----------------------------------------------------------------------
#                          Make Directories
# ----------------------------------------------------------------------

# Make full path names to locations
LIB_BUILD_DIR=${BUILD_DIR}/${PKG}/${PKG_VERSION}
LIB_INSTALL_DIR=${INSTALL_DIR}/${PKG}/${PKG_VERSION}

# Clean if they already exist
rm -rf ${LIB_BUILD_DIR}
rm -rf ${LIB_INSTALL_DIR}

# ----------------------------------------------------------------------
#                        Download (if Needed)
# ----------------------------------------------------------------------

LOCAL_DOWNLOAD_NAME=${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.gz

if [[ "$OSTYPE" == "linux"* ]]; then
    if [[ "$PKG_VERSION" == "5.9.1" ]]; then
        REMOTE_DOWNLOAD_NAME="https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.9&type=binary&os=Linux&downloadFile=ParaView-5.9.1-MPI-Linux-Python3.8-64bit.tar.gz"
    elif [[ "$PKG_VERSION" == "5.10.1" ]]; then
        REMOTE_DOWNLOAD_NAME="https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.10&type=binary&os=Linux&downloadFile=ParaView-5.10.1-MPI-Linux-Python3.9-x86_64.tar.gz"
    else
        echo "ERROR: Version ${PKG_VERSION} Needs Link"
        exit -1
    fi        
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ "$PKG_VERSION" == "5.9.1" ]]; then
        REMOTE_DOWNLOAD_NAME="https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.9&type=binary&os=macOS&downloadFile=ParaView-5.9.1-MPI-OSX10.13-Python3.8-64bit.pkg"
    elif [[ "$PKG_VERSION" == "5.10.1" ]]; then
        REMOTE_DOWNLOAD_NAME="https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.10&type=binary&os=macOS&downloadFile=ParaView-5.10.1-MPI-OSX10.13-Python3.9-x86_64.pkg"
    else
        echo "ERROR: Version ${PKG_VERSION} Needs Link"
        exit -1
    fi 
fi

if [[ ! -f "${LOCAL_DOWNLOAD_NAME}" ]]; then
    ${DOWNLOAD_CMD} ${LOCAL_DOWNLOAD_NAME} ${REMOTE_DOWNLOAD_NAME}
fi

# ----------------------------------------------------------------------
#                            UnPack + Install
# ----------------------------------------------------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "ERROR: Need to Figure Out How to Unpack PKG into Custom Location"
    exit -1
fi

# Untar the tarball
tar --strip-components 1 -xvf ${TAR_DIR}/${tar_file_name}

# Create installation directory
mkdir -p ${LIB_INSTALL_DIR}

# Move Unpacked into installation directory
mv ${LIB_BUILD_DIR}/* ${LIB_INSTALL_DIR}/.

# ----------------------------------------------------------------------
#                            Create Module File
# ----------------------------------------------------------------------

# Create Module File
mkdir -p ${MODULE_DIR}/base/${PKG}
cat << EOF > ${MODULE_DIR}/base/${PKG}/${PKG_VERSION}.lua

help([[ ${PKG} version ${PKG_VERSION} ]])
family("paraview")

-- Conflicting modules

-- Modulepath for packages built by this compiler

-- Environment Paths
prepend_path("PATH",     "${LIB_INSTALL_DIR}/bin")

-- Environment Variables
EOF
