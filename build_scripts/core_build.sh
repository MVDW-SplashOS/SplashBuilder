#!/bin/bash

# 
# SplashOS Builder
#
# ----------------
#
# This tool is made to create a full SplashOS install.
#  



export DIST_ROOT=$(pwd)

# All steps required to build SplashOS:
# 
#
#
# Step 2:
#     |
#


source ./build_scripts/functions/reset_enviroment.sh
# -------------------------------------------------------------
#
#      STEP 2: Compiling a cross-toolchain
#
# -------------------------------------------------------------


source build_scripts/build/binutils-pass-1.sh "binutils-${config_tools_list__binutils__version}.tar.xz"
source build_scripts/build/gcc-pass-1.sh "gcc-${config_tools_list__gcc__version}.tar.xz"
source build_scripts/build/linux-headers.sh "linux-${config_tools_list__linux__version}.tar.xz"
source build_scripts/build/glibc.sh "glibc-${config_tools_list__glibc__version}.tar.xz"
source build_scripts/build/libstdcpp-pass-1.sh "gcc-${config_tools_list__gcc__version}.tar.xz"


# -------------------------------------------------------------
#
#      STEP 3: Cross Compiling Temporary Tools
#
# -------------------------------------------------------------

source build_scripts/build/m4.sh "m4-${config_tools_list__m4__version}.tar.xz"
source build_scripts/build/ncurses.sh "ncurses-${config_tools_list__ncurses__version}.tar.gz"
source build_scripts/build/bash.sh "bash-${config_tools_list__bash__version}.tar.gz"
source build_scripts/build/coreutils.sh "coreutils-${config_tools_list__coreutils__version}.tar.xz"
source build_scripts/build/diffutils.sh "diffutils-${config_tools_list__diffutils__version}.tar.xz"
source build_scripts/build/file.sh "file-${config_tools_list__file__version}.tar.gz"
source build_scripts/build/findutils.sh "findutils-${config_tools_list__findutils__version}.tar.xz"
source build_scripts/build/gawk.sh "gawk-${config_tools_list__gawk__version}.tar.xz"
source build_scripts/build/grep.sh "grep-${config_tools_list__grep__version}.tar.xz"
source build_scripts/build/gzip.sh "gzip-${config_tools_list__gzip__version}.tar.xz"
source build_scripts/build/make.sh "make-${config_tools_list__make__version}.tar.gz"
source build_scripts/build/patch.sh "patch-${config_tools_list__patch__version}.tar.xz"
source build_scripts/build/sed.sh "sed-${config_tools_list__sed__version}.tar.xz"
source build_scripts/build/tar.sh "tar-${config_tools_list__tar__version}.tar.xz"
source build_scripts/build/xz.sh "xz-${config_tools_list__xz__version}.tar.xz"
source build_scripts/build/binutils-pass-2.sh "binutils-${config_tools_list__binutils__version}.tar.xz"
source build_scripts/build/gcc-pass-2.sh "gcc-${config_tools_list__gcc__version}.tar.xz"

