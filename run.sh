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

# Build environment
# These are normally set in ~/.bashrc (see prepare/modify_enviroment.sh), but
# that file is only sourced by *interactive* shells, so 'sudo ./run.sh' does
# not have them. Define them here so they are always present.
#
# The build target location comes from the PATH SECTION of config.yml:
#   path_type: directory  -> build in a plain directory (path_build)
#   path_type: partition  -> mount path_device on path_build, build there
# (partitions.sh performs the mount; everything downstream uses
# $splash_partition_root).
case "${config_path_build:-}" in
	"")
		printf $BRed
		printf "ERROR: "
		printf $IRed
		printf "config.yml has no path_build set.\n"
		exit 2
		;;
	*) ;;
esac
export splash_partition_root="$config_path_build"
export SPLASHOS_TGT="$(uname -m)-splash-linux-gnu"
export CONFIG_SITE="$splash_partition_root/usr/share/config.site"

# Unmount virtual kernel filesystems left over from a previous (interrupted)
# session BEFORE the prepare phase — core_prepare does a recursive chmod over
# the build tree, which fails on mounted proc/sys (Operation not permitted)
# and aborts the build.
if mountpoint -q $splash_partition_root/dev/shm; then
	umount $splash_partition_root/dev/shm
fi

if mountpoint -q $splash_partition_root/dev/pts; then
	umount $splash_partition_root/dev/pts
fi

if mountpoint -q $splash_partition_root/dev; then
	umount $splash_partition_root/dev
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

source ./SplashBuilder/core_prepare.sh










# Ask whether to recover the previous build (if a snapshot exists)
recover_build=false
case "$1" in
	recover) recover_build=true ;;
esac

if [ "$recover_build" = false ] && [ -f "$splash_partition_root/.build_state" ]; then
	printf $BIYellow
	printf "A previous build snapshot was found in $splash_partition_root\n"
	printf "Recover the build from it instead of starting over? (y/N) "
	printf $White
	printf " "
	read recover_choice
	case "$recover_choice" in
		y|Y) recover_build=true ;;
	esac
fi

if [ "$recover_build" = true ]; then
	echo "Recovering previous build..."
else
	source ./SplashBuilder/utils/reset_enviroment.sh
	source ./SplashBuilder/core_build.sh fresh
fi

if [ "$recover_build" = true ]; then
	source ./SplashBuilder/core_build.sh recover
fi


separator
echo "SplashOS has been fully build!"

