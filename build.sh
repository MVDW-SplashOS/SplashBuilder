#!/bin/bash

# 
# SplashOS Builder
#
# ----------------
#
# This tool is made to create a full SplashOS install.
#  

# Include color code
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



ask_continue() {
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
			ask_continue;;
	esac
}
ask_continue

# Override localisation settings
export LC_ALL=C


# Step 1 - Check, install and configure host system
source ./build_scripts/prepare/system_requirements.sh

# Step 2 - Make partitions
source ./build_scripts/prepare/partitions.sh
