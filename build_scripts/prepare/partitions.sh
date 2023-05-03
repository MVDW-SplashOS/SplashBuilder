#!/bin/bash

# 
# SplashOS Builder - Partition Script
#
# ----------------
#
# This script makes partitions used to build the system on.
#  

mapfile -t disks < <(sudo fdisk -l | awk '/^\/dev/ {print $1}')

splash_partition_root_device=/dev/vda4
splash_partition_root=/mnt/splashos

printf $Blue

echo "---------------------------------------------------"
echo "Please select the partition to build SplashOS on: "
count_partitions=-1

for line in "${disks[@]}"; do
	count_partitions=$(($count_partitions+1))
	printf "[${count_partitions}] "
	printf $line
	printf "\n"
	
done

printf $BBlue
printf "Where should SplashOS be installed on [0-${count_partitions}]?"
printf $White
printf " "


echo "${disks[2]}";



#yes | mkfs -v -t ext4 $splash_partition_root_device 


mkdir -p $splash_partition_root

if findmnt -rno source $splash_partition_root; then
	echo "Partition already mounted"
else
	echo "Partition not mounted, mounting..."
	#mount -v -t ext4 $splash_partition_root_device /mnt/splashos
fi



