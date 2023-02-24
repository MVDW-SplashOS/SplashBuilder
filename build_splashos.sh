#!/bin/bash

# 
# SplashOS Builder
#
# ----------------
#
# This tool is made to create a full SplashOS install.
#  

# Include dependency's
source ./build_scripts/global_functions.sh
source ./build_scripts/style/color.sh

set -e

# check if correct user is running script.
if [ $USER != "splashbuilder" ]; then
        printf $BRed
	printf "ERROR: "
	printf $IRed
	printf "Please run this script as splashbuilder.\n"
	exit 2
fi



# Print SplashOS builder info
source ./build_scripts/style/print_logo.sh
printf "\n\n"

# Notify user its safer to run in vm
printf $BIYellow
printf "WARNING: "
printf $Yellow
printf "This script will reconfigure your system and install packages to build SplashOS.\n"
printf "This script might break your system so use at your own risk, use a virtual machine to be safe.\n\n"


f_prompt "Do you want to continue (y/n)?"

# Override localisation settings
export LC_ALL=C


# Loading the config file 
export yaml_file=./config.yml
export yaml_prefix="config_"
source ./build_scripts/parse_yaml.sh
create_variables 


# All steps required to build SplashOS:
# 
#
#
# Step 2:
#     |
#



# -------------------------------------------------------------
#
#      STEP 2: Compiling a cross-toolchain
#
# -------------------------------------------------------------


bash -e build_scripts/build/binutils-pass-1.sh "binutils-${config_tools_list__binutils__version}.tar.xz"
bash -e build_scripts/build/gcc-pass-1.sh "gcc-${config_tools_list__gcc__version}.tar.xz"
bash -e build_scripts/build/linux-headers.sh "linux-${config_tools_list__linux__version}.tar.xz"
bash -e build_scripts/build/glibc.sh "glibc-${config_tools_list__glibc__version}.tar.xz"
#bash -e build_scripts/build/libstdcpp-pass-1.sh "gcc-${config_tools_list__gcc__version}.tar.xz"


echo $MAKEFLAGS

echo "Splash Builder Done."
