#!/bin/bash

# 
# SplashOS Builder
#
# ----------------
#
# This tool is made to create a full SplashOS install.
#  


echo ${splash_partition_root:?}
echo ${SPLASHOS_TGT:?}

# Copy Required scripts to the Chroot Enviroment
cp -r ./build_scripts/chroot/* $splash_partition_root
cp -r ./build_scripts/functions/parse_yaml.sh $splash_partition_root/splash_builder
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
cat << EOF | sudo chroot "$splash_partition_root" /usr/bin/env -i HOME=/root TERM="$TERM" PS1='(splash chroot) \u:\w\$ ' PATH=/usr/bin:/usr/sbin /bin/bash --login
./prepare_chroot.sh
EOF

echo "------------------------"
echo "SplashOS has been fully build!"
