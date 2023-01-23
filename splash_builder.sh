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

# check if root perms.
if [ "$EUID" -ne 0 ]
then
	printf $BRed
	printf "ERROR: "
	printf $IRed
	printf "Please run this as root or with sudo\n"
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


# Step 1 - Check, install and configure host system
source ./build_scripts/prepare/system_requirements.sh

# Step 2 - Make partitions
source ./build_scripts/prepare/partitions.sh

# Step 3 - Download dependencies
source ./build_scripts/prepare/dependencies.sh


echo "Splash Builder Done."
