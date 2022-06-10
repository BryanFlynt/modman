#export PWD=$(shell pwd)
export BUILD_DIR=${PWD}/build
export INSTALL_DIR=${PWD}/apps
export TAR_DIR=${PWD}/downloads
export SRC_DIR=${PWD}/src
export LOG_DIR=${PWD}/log
export MODULE_DIR=${PWD}/modulefiles

N=4
NPROC_RESULT=$(getconf _NPROCESSORS_ONLN)
export MOD_NPROC=$(( NPROC_RESULT > N ? NPROC_RESULT : N ))
