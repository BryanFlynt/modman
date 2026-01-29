#!/bin/bash -l
#
# =========================================
#
# Script is always called as:
# > build.sh <package> <package_version> <compiler> <compiler_version> <mpi> <mpi_version>
#
# Constructs a log file name which looks like:
# ${LOG_DIR}/<package>_<package_version>_<compiler>_<compiler_version>_<mpi>_<mpi_version>.log
#
# Calls the package script as
# ${SRC_DIR}/<package>.sh <package_version> <compiler> <compiler_version> <mpi> <mpi_version>
#
# =========================================

# Abort if any command returns an error
set -e

# Record what we're doing
set -x

# Set the package name and version
export PKG=$1
export PKG_VERSION=$2

# Get Compiler and version
export COMPILER=$3
export COMPILER_VERSION=$4

# Get MPI and version
export MPI=$5
export MPI_VERSION=$6

# Create log directory if not exist
mkdir -p ${LOG_DIR}

# Construct a log file name
logfile=${LOG_DIR}/${PKG}
if [ -n "${PKG_VERSION}" ]; then
    logfile="${logfile}_${PKG_VERSION}"
fi
if [ -n "${COMPILER}" ]; then
    logfile="${logfile}_${COMPILER}"
fi
if [ -n "${COMPILER_VERSION}" ]; then
    logfile="${logfile}_${COMPILER_VERSION}"
fi
if [ -n "${MPI}" ]; then
    logfile="${logfile}_${MPI}"
fi
if [ -n "${MPI_VERSION}" ]; then
    logfile="${logfile}_${MPI_VERSION}"
fi
logfile="${logfile}.log"

# Start a shell block with redirected IO to log file
{

# Make sure the stacksize is something reasonable
ulimit -s 8192

# Create the log directory if necessary
mkdir -p ${LOG_DIR}

echo "Building ${PKG}-${PKG_VERSION}"

eval ${SRC_DIR}/${PKG}.sh ${PKG_VERSION} ${COMPILER} ${COMPILER_VERSION} ${MPI} ${MPI_VERSION}

} 2>&1 | tee ${logfile}  # End of shell block with redirected IO

exit "${PIPESTATUS[0]}"
