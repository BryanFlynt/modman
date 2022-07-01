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

# Create the build directory to unpack
mkdir -p ${LIB_BUILD_DIR}
cd ${LIB_BUILD_DIR}

# ----------------------------------------------------------------------
#                        Download (if Needed)
# ----------------------------------------------------------------------



if [[ "$OSTYPE" == "linux"* ]]; then
    LOCAL_DOWNLOAD_NAME=${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.gz
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
	PACKAGE_NAME="ParaView-5.9.1-MPI-OSX10.13-Python3.8-64bit"
	LOCAL_DOWNLOAD_NAME=${TAR_DIR}/${PACKAGE_NAME}.dmg
        REMOTE_DOWNLOAD_NAME="https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.9&type=binary&os=macOS&downloadFile=${PACKAGE_NAME}.dmg"
    elif [[ "$PKG_VERSION" == "5.10.1" ]]; then
	PACKAGE_NAME="ParaView-5.10.1-MPI-OSX10.13-Python3.9-x86_64"
	LOCAL_DOWNLOAD_NAME=${TAR_DIR}/${PACKAGE_NAME}.dmg
	REMOTE_DOWNLOAD_NAME="https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.10&type=binary&os=macOS&downloadFile=${PACKAGE_NAME}.dmg"
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
#if [[ "$OSTYPE" == "darwin"* ]]; then
#    echo "ERROR: Need to Figure Out How to Unpack PKG into Custom Location"
#    exit -1
#fi


# Create Installation Directory
mkdir -p ${LIB_INSTALL_DIR}

if [[ "$OSTYPE" == "linux"* ]]; then
    cd ${LIB_INSTALL_DIR}
    tar --strip-components 1 -xvf ${LOCAL_DOWNLOAD_NAME}
    
elif [[ "$OSTYPE" == "darwin"* ]]; then

    # Mount the Downloaded Image, mv, then unmount
    yes | hdiutil attach ${LOCAL_DOWNLOAD_NAME}
    cp -r /Volumes/${PACKAGE_NAME}/ParaView-${PKG_VERSION}.app/Contents/* ${LIB_INSTALL_DIR}/.
    hdiutil detach /Volumes/${PACKAGE_NAME}
fi

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
prepend_path("PATH",     "${LIB_INSTALL_DIR}/MacOS")

-- Environment Variables
EOF
