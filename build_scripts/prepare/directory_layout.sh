#!/usr/bin/env bash

mkdir -pv $splash_partition_root/{etc,var,lib64,tools} $splash_partition_root/usr/{bin,lib,sbin}

for i in bin lib sbin; do
  ln -sv usr/$i $splash_partition_root/$i
done

