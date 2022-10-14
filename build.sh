#!/bin/sh

# 
# SplashOS Builder
# ----------------
# This tool is made to create a full SplashOS install.
#  

# check if root perms.
if [ "$EUID" -ne 0 ]
then
    echo "Please run this as root or with sudo"
    exit 2
fi

source ./build_env/prepare_scripts/install_requirements.sh
source ./build_env/prepare_scripts/version_check.sh
source ./build_env/prepare_scripts/quick_env_export.sh
source ./build_env/prepare_scripts/prepare_build.sh
source ./build_env/create.sh
echo "------------------------------------------"
echo "done."
