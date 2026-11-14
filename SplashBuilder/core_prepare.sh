#!/bin/bash


# All steps required to build SplashOS:
# 
# Step 1: Prepare the host system
#     |
#     |-- 1.0 - Check, install and configure host system
#     |
#     |-- 1.1 - Make partitions
#     |
#     |-- 1.2 - Download dependencies
#     |
#     |-- 1.3 - Create directory layout
#     |
#     |-- 1.4 - Setup bash enviroment
#
#



# -------------------------------------------------------------
#
#      STEP 1: Prepare the host system
#
# -------------------------------------------------------------

# Step 1.0 - Check, install and configure host system
source ./SplashBuilder/prepare/system_requirements.sh

# Step 1.1 - Make partitions
source ./SplashBuilder/prepare/partitions.sh

# Step 1.2 - Download dependencies
source ./SplashBuilder/prepare/dependencies.sh

# Step 1.3 - Create directory layout
source ./SplashBuilder/prepare/directory_layout.sh

# Step 1.4 - Setup bash enviroment
source ./SplashBuilder/prepare/modify_enviroment.sh

# Make the build tree writable. Virtual kernel filesystems (proc, sys, dev,
# run) are skipped: if a previous session left them mounted, chmod cannot
# touch their contents (Operation not permitted) and would abort the build.
find $splash_partition_root -mindepth 1 -maxdepth 1 \
	! -name proc ! -name sys ! -name dev ! -name run \
	-exec chmod -R 777 {} +
