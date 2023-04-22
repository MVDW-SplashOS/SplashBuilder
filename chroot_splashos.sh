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


# TEMPORARY: Setup required variables.
export splash_partition_root=/mnt/splashos
export SPLASHOS_TGT=$(uname -m)-splash-linux-gnu

echo $splash_partition_root

# Copy Required scripts to the Chroot Enviroment
cp -r ./build_scripts/chroot/* $splash_partition_root
cp -r ./build_scripts/parse_yaml.sh $splash_partition_root/splash_builder
cp -r ./config.yml $splash_partition_root

# Copy sources directory to Chroot enviroment
cp -r ./sources $splash_partition_root

# Change Ownership
chown -R root:root $splash_partition_root/{usr,lib,var,etc,bin,sbin,tools,lib64}

# Preparing Virtual Kernel File System
mkdir -pv $splash_partition_root/{dev,proc,sys,run}

mount -v --bind /dev $splash_partition_root/dev

mount -v --bind /dev/pts $splash_partition_root/dev/pts
mount -vt proc proc $splash_partition_root/proc
mount -vt sysfs sysfs $splash_partition_root/sys
mount -vt tmpfs tmpfs $splash_partition_root/run


if [ -h $splash_partition_root/dev/shm ]; then
  mkdir -pv $splash_partition_root/$(readlink $splash_partition_root/dev/shm)
else
  mount -t tmpfs -o nosuid,nodev tmpfs $splash_partition_root/dev/shm
fi




# Enter Chroot Enviroment
chroot "$splash_partition_root" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(splash chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    /bin/bash --login






echo "----------------------------------"
echo "The preperation of the build enviroment has been finished!"
echo "please run the build_splashos.sh as user splashbuilder with 'su splashbuilder'"
