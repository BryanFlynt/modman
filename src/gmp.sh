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
export PKG=gmp
export PKG_VERSION=$1

# ----------------------------------------------------------------------
#                        Download (if Needed)
# ----------------------------------------------------------------------

LOCAL_DOWNLOAD_NAME=${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.xz
REMOTE_DOWNLOAD_NAME="https://gmplib.org/download/gmp/gmp-${PKG_VERSION}.tar.xz"

if [[ ! -f "${LOCAL_DOWNLOAD_NAME}" ]]; then
    ${DOWNLOAD_CMD} ${LOCAL_DOWNLOAD_NAME} ${REMOTE_DOWNLOAD_NAME}
fi
