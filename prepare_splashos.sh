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


# All steps required to build SplashOS:
# 
# Step 1: Prepare the host system
#     |
#     |-- 1.0 - Check, install and configure host system
#     |
#     |-- 1.1 - Make partitions
#     |
#     |-- 1.2 - Download dependencies
#     |
#     |-- 1.3 - Create directory layout
#     |
#     |-- 1.4 - Setup bash enviroment
#
#
# Step 2:
#     |
#



# -------------------------------------------------------------
#
#      STEP 1: Prepare the host system
#
# -------------------------------------------------------------

# Step 1.0 - Check, install and configure host system
source ./build_scripts/prepare/system_requirements.sh

# Step 1.1 - Make partitions
source ./build_scripts/prepare/partitions.sh

# Step 1.2 - Download dependencies
source ./build_scripts/prepare/dependencies.sh

# Step 1.3 - Create directory layout
source ./build_scripts/prepare/directory_layout.sh

# Step 1.4 - Create and setup SplashBuilder user
source ./build_scripts/prepare/create_user.sh



test="fail"
su splashbuilder <<EOSU
echo 'test ${test} ${splash_partition_root} :: $(whoami)'

EOSU

exit;
#su -l splashbuilder -c 'test -n "${splash_partition_root}" || { echo "splash_partition_root is not set for user $(whoami) : $splash_partition_root"; exit 1; }; echo "${splash_partition_root}"' 
su -s /bin/bash -c 'test -n "$SPLASHOS_TGT" || { echo "SPLASHOS_TGT is not set $(whoami)"; exit 1; }; echo "$SPLASHOS_TGT"' splashbuilder



echo "Splash Builder Done."
