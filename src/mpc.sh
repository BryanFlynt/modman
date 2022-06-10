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
export PKG=mpc
export PKG_VERSION=$1

# ----------------------------------------------------------------------
#                        Download (if Needed)
# ----------------------------------------------------------------------

LOCAL_DOWNLOAD_NAME=${TAR_DIR}/${PKG}-${PKG_VERSION}.tar.gz
REMOTE_DOWNLOAD_NAME="https://ftp.gnu.org/gnu/mpc/mpc-${PKG_VERSION}.tar.gz"

if [[ ! -f "${LOCAL_DOWNLOAD_NAME}" ]]; then
    ${DOWNLOAD_CMD} ${LOCAL_DOWNLOAD_NAME} ${REMOTE_DOWNLOAD_NAME}
fi
