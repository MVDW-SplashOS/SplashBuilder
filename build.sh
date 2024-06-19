#!/bin/bash

# 
# SplashOS Builder
#
# ----------------
#
# This tool is made to create a full SplashOS install.
#  

# Include dependency's
source ./build_scripts/functions/color.sh

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
source ./build_scripts/functions/print_logo.sh
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


# Include and parse yaml script
export yaml_file=./config.yml
export yaml_prefix="config_"
source ./build_scripts/functions/parse_yaml.sh
create_variables 

source ./build_scripts/core_prepare.sh
source ./build_scripts/core_build.sh

source ./build_scripts/core_chroot.sh


echo "------------------------"
echo "SplashOS has been fully build!"

