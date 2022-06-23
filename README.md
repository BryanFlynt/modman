# modman
Module Manager for Software Installation 

## Prerequisite
- brew install coreutils
  - To resolve directory names using realpath (or greadlink)
- brew install lmod
  - Provide the Lua-based environment modules

## SetUp
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
export MODULEPATH=/Users/${USER}/opt/modmand/modulefiles/base
```
