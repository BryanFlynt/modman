# modman
Module Manager for Software Installation 

## Prerequisite
- brew install coreutils
  - To resolve directory names using realpath (or greadlink)
- brew install lmod
  - Provide the Lua-based environment modules

## File Placement
The scripts are configured to install everything within the "modman" directory that
a user has cloned (or placed) on the system.  This behavior can be modified from within the 
"config.mk" file but it's not very well tested. For the purpose of these examples we 
will assume "modman" is placed within a directory named "opt" within the users home 
directory and "config.mk" uses the default values.

```bash
> cd ${HOME}
> mkdir opt
> git clone https://github.com/BryanFlynt/modman.git
> cd modman
> git checkout machine/macos
```

## SetUp
Many of the build+install recipes have dependencies that are loaded using LMod. 
Therefore, you must prepare your environment to look for the soon to be created
modules **before** you make any targets.

- Set paths for Environment Modules
  - Modify ~/.bashrc file to include

```bash
#
# Pick up the LMod package
#
source /usr/local/opt/lmod/init/profile

#
# Set the LMod variable to the root of your module files
#
# NOTE:
# This should match the path listed within the modman/config.mk file
# export MODULEPATH=${MODULE_DIR}/base
#
export MODULEPATH=/Users/${USER}/opt/modman/modulefiles/base
```

## Build Targets
Any target can be created along with it's dependencies using
```bash
> make <target_name>
```

### All Targets
Make and install everything is the default behavior
```bash
> make all
```

### Select Targets
To find a list of available targets look within "rules.mk" which is a standard Makefile.
Notice this file contains both dependencies and the end libraries a user may be after so 
it can be quite confusing as to what order things need to be built.  As a result, it may 
be simplest to just select your end goal and allow make to determine the build order.

For example:
To build Boost with MPI support compiled with GCC a user might find it simpler to just attempt 
and make that target.
```bash
> make boost-mpi-gcc
```

## Clean Up
The build process will automatically keep the original download, build directories and logs which 
can get very large.  To eliminate this unnecessary memory usage three targets have been created 
within the "rules.mk" file.

- Remove logs and build directories
```bash
> make clean
```

- Remove logs, builds and original downloads
```bash
> make cleanmem
```

- Remove everything (logs, builds, downloads, modules and *applications*)  
```bash
> make cleanall
```

