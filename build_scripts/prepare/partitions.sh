#!/bin/bash

# 
# SplashOS Builder - Partition Script
#
# ----------------
#
# This script makes partitions used to build the system on.
#  

mapfile -t disks < <(sudo fdisk -l | awk '/^\/dev/ {print $1}')

echo "Please select the partition to build SplashOS on: "
count_partitions=-1

for line in "${disks[@]}"; do
	count_partitions=$(($count_partitions+1))
	printf "[${count_partitions}] "
	printf $line
	printf "\n"
	
done


echo "Where should SplashOS be installed on [0-${count_partitions}]? "

#mkfs -v -t ext4 /dev/splashos


