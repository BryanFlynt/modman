#!/bin/bash

wget "https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2-linux-x86_64.tar.gz"
wget "https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2-macos-universal.tar.gz"

wget "https://mirrors.kernel.org/gnu/gcc/gcc-11.1.0/gcc-11.1.0.tar.gz"

wget "https://mirrors.kernel.org/gnu/gcc/gcc-11.3.0/gcc-11.3.0.tar.gz"


wget "https://www.mpfr.org/mpfr-3.1.4/mpfr-3.1.4.tar.bz2"
wget "https://www.mpfr.org/mpfr-4.1.0/mpfr-4.1.0.tar.bz2"

wget "https://gmplib.org/download/gmp/gmp-6.1.0.tar.lz"
wget "https://gmplib.org/download/gmp/gmp-6.2.1.tar.lz"

wget "http://isl.gforge.inria.fr/isl-0.18.tar.bz2"
wget "http://isl.gforge.inria.fr/isl-0.24.tar.bz2"

wget "https://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz"
wget "https://ftp.gnu.org/gnu/mpc/mpc-1.2.1.tar.gz"


wget "https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.1.tar.bz2"

wget "https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.bz2"
mv boost_1_76_0.tar.bz2 boost-1.76.0.tar.bz2

wget "https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source/boost_1_77_0.tar.bz2"
mv boost_1_77_0.tar.bz2 boost-1.77.0.tar.bz2

wget "https://github.com/xianyi/OpenBLAS/releases/download/v0.3.15/OpenBLAS-0.3.15.tar.gz"
mv OpenBLAS-0.3.15.tar.gz openblas-0.3.15.tar.gz

wget "https://github.com/flame/blis/archive/refs/tags/0.8.1.tar.gz"
mv 0.8.1.tar.gz blis-0.8.1.tar.gz

wget "https://github.com/llvm/llvm-project/archive/llvmorg-9.0.0.zip"

wget "https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/llvm-project-12.0.0.src.tar.xz"
mv llvm-project-12.0.0.src.tar.xz llvm-12.0.0.tar.xy

wget "https://github.com/llvm/llvm-project/releases/download/llvmorg-14.0.0/llvm-project-14.0.0.src.tar.xz"
mv llvm-project-14.0.0.src.tar.xz llvm-14.0.0.tar.xy

wget "https://registrationcenter-download.intel.com/akdlm/irc_nas/17769/l_BaseKit_p_2021.2.0.2883_offline.sh"
mv l_BaseKit_p_2021.2.0.2883_offline.sh oneapi_base-2021.2.0.sh

wget "https://registrationcenter-download.intel.com/akdlm/irc_nas/17764/l_HPCKit_p_2021.2.0.2997_offline.sh"
mv l_HPCKit_p_2021.2.0.2997_offline.sh oneapi_hpc-2021.2.0.sh

wget "https://registrationcenter-download.intel.com/akdlm/irc_nas/17977/l_BaseKit_p_2021.3.0.3219_offline.sh"
mv l_BaseKit_p_2021.3.0.3219_offline.sh oneapi_base-2021.3.0.sh

wget "https://registrationcenter-download.intel.com/akdlm/irc_nas/17912/l_HPCKit_p_2021.3.0.3230_offline.sh"
mv l_HPCKit_p_2021.3.0.3230_offline.sh oneapi_hpc-2021.3.0.sh

wget --content-disposition "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"
mv code-stable-x64*.tar.gz vscode-1.56.2.tar.gz

wget "https://github.com/jmrosinski/GPTL/releases/download/v8.0.3/gptl-8.0.3.tar.gz"

wget "https://download.open-mpi.org/release/hwloc/v2.4/hwloc-2.4.1.tar.bz2"

wget "https://github.com/openucx/ucx/releases/download/v1.10.1/ucx-1.10.1.tar.gz"

wget "https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz"
mv libevent-2.1.12-stable.tar.gz libevent-2.1.12.tar.gz

wget --content-disposition "https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.9&type=binary&os=Linux&downloadFile=ParaView-5.9.1-MPI-Linux-Python3.8-64bit.tar.gz"
mv ParaView-5.9.1-MPI-Linux-Python3.8-64bit.tar.gz paraview-5.9.1.tar.gz

wget https://developer.download.nvidia.com/compute/cuda/11.3.1/local_installers/cuda_11.3.1_465.19.01_linux.run
p="cuda*"; old_name=$(ls | grep $p); new_name=$(ls | grep $p | sed 's/_/-/g'); mv $old_name $new_name

git clone https://github.com/MentorEmbedded/nvptx-tools
tar zcvf nvptx-tools-0.0.0.tar.gz nvptx-tools
rm -rf nvptx-tools

git clone https://github.com/MentorEmbedded/nvptx-newlib
tar zcvf nvptx-newlib-0.0.0.tar.gz nvptx-newlib
rm -rf nvptx-newlib

wget https://developer.download.nvidia.com/hpc-sdk/21.5/nvhpc_2021_215_Linux_x86_64_cuda_11.3.tar.gz
mv nvhpc_2021_215_Linux_x86_64_cuda_11.3.tar.gz nvhpc-21.5.tar.gz

wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
mv Anaconda3-2021.05-Linux-x86_64.sh anaconda-2021.5.sh

wget https://github.com/oneapi-src/oneTBB/archive/refs/tags/v2021.3.0.tar.gz
mv v2021.3.0.tar.gz tbb-2021.3.0.tar.gz

wget https://gmsh.info/bin/Linux/gmsh-4.8.4-Linux64.tgz

# LLVM with CUDA + SYCL
wget https://github.com/intel/llvm/archive/refs/heads/sycl.tar.gz
mv sycl.tar.gz sycl-2021.8.16.tar.gz

# HDF5
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.12/hdf5-1.12.1/src/hdf5-1.12.1.tar.gz

# NetCDF
wget https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.8.1.tar.gz
mv v4.8.1.tar.gz netcdf-c-4.8.1.tar.gz

wget https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-cxx4-4.3.1.tar.gz
mv netcdf-cxx4-4.3.1.tar.gz netcdf-cxx-4.3.1.tar.gz

wget https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.5.3.tar.gz
mv netcdf-fortran-4.5.3.tar.gz netcdf-f-4.5.3.tar.gz


# AStyle
wget https://sourceforge.net/projects/astyle/files/astyle/astyle%203.1/astyle_3.1_linux.tar.gz
mv astyle_3.1_linux.tar.gz astyle-3.1.0.tar.gz

# Ninja
wget https://github.com/ninja-build/ninja/archive/refs/tags/v1.10.2.tar.gz
mv v1.10.2.tar.gz ninja-1.10.2.tar.gz

# PAPI
wget https://bitbucket.org/icl/papi/get/papi-6-0-0-1-t.tar.gz
mv papi-6-0-0-1-t.tar.gz papi-6.0.0.tar.gz





