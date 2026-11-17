#!/bin/bash

# 
# SplashOS Builder - Partition Script
#
# ----------------
#
# This script makes partitions used to build the system on.
#  

mapfile -t disks < <(sudo fdisk -l | awk '/^\/dev/ {print $1}')

# Target locations come from the PATH SECTION of config.yml (parsed by
# run.sh): path_type "partition" mounts path_device on path_build, path_type
# "directory" builds directly inside the path_build directory. No mkfs here:
# the partition is expected to be formatted already (a fresh build wipes it
# in reset_enviroment.sh anyway).
splash_partition_root="$config_path_build"

printf $Blue

echo "---------------------------------------------------"
echo "Partitions available on this system:"
count_partitions=-1

for line in "${disks[@]}"; do
	count_partitions=$(($count_partitions+1))
	printf "[${count_partitions}] "
	printf $line
	printf "\n"

done

printf $White


if [ "$config_path_type" = "partition" ]; then
	mkdir -p $splash_partition_root

	if findmnt -rno source $splash_partition_root; then
		echo "Partition already mounted"
	else
		echo "Partition not mounted, mounting $config_path_device on $splash_partition_root..."
		mount -v $config_path_device $splash_partition_root
	fi
else
	mkdir -p $splash_partition_root
fi


