#!/bin/bash

# 
# SplashOS Builder
#
# ----------------
#
# This tool is made to create a full SplashOS install.
#  

# Include dependency's
source ./SplashBuilder/utils/color.sh
source ./SplashBuilder/utils/echo.sh

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
source ./SplashBuilder/utils/print_logo.sh
printf "\n\n"

# Notify user its safer to run in vm
printf $BIYellow
printf "WARNING: "
printf $Yellow
printf "This script will reconfigure your system and install packages to build SplashOS.\n"
printf "This script might break your system so use at your own risk, use a virtual machine to be safe.\n\n"


f_prompt() {
	printf $UBlue
	printf "Do you want to continue (y/n)?"
	printf $White 
	printf " "
	read choice

	case "$choice" in 
		y|Y )
			printf "Continueing operation...\n\n";;
			
		n|N )
			printf "Quitting...\n\n"
			
			exit 1;;
		* )
			printf "invalid awnser\n\n" 
			f_prompt;;
	esac
}

f_prompt

export LC_ALL=C
export builder_currentstep=0
export builder_currentstep_env=0

# Include and parse yaml script
export yaml_file=./config.yml
export yaml_prefix="config_"
source ./SplashBuilder/utils/parse_yaml.sh
create_variables 

source ./SplashBuilder/core_prepare.sh


# Unmount all drives
if mountpoint -q $splash_partition_root/dev; then
	umount $splash_partition_root/dev
fi

if mountpoint -q $splash_partition_root/dev/pts; then
	umount $splash_partition_root/dev/pts
fi

if mountpoint -q $splash_partition_root/proc; then
	umount $splash_partition_root/proc
fi

if mountpoint -q $splash_partition_root/sys; then
	umount $splash_partition_root/sys
fi

if mountpoint -q $splash_partition_root/run; then
	umount $splash_partition_root/run
fi

if mountpoint -q $splash_partition_root/dev/shm; then
	umount $splash_partition_root/dev/shm
fi










source ./SplashBuilder/utils/reset_enviroment.sh
source ./SplashBuilder/core_build.sh


separator
echo "SplashOS has been fully build!"

