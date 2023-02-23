#!/usr/bin/env bash

mkdir -pv $splash_partition_root/{etc,var,lib64,tools} $splash_partition_root/usr/{bin,lib,sbin}

for i in bin lib sbin; do
	if ! [[ -L "$splash_partition_root/$i" ]]; then
		ln -sv "usr/$i" "$splash_partition_root/$i"
	else
		echo "Symlink '$splash_partition_root/$i' already exist, skipping.."
	fi
done

