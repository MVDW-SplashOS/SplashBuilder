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
source ./build_scripts/prepare/system_requirements.sh

# Step 1.1 - Make partitions
source ./build_scripts/prepare/partitions.sh

# Step 1.2 - Download dependencies
source ./build_scripts/prepare/dependencies.sh

# Step 1.3 - Create directory layout
source ./build_scripts/prepare/directory_layout.sh

# Step 1.4 - Create and setup SplashBuilder user
source ./build_scripts/prepare/create_user.sh

chmod 777 -R $splash_partition_root
