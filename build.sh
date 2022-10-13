#!/bin/sh

# 
# SplashOS Builder
# ----------------
# This tool is made to create a full SplashOS install.
#  

# check if root perms.
if [[ "$EUID" = 0 ]]; then
    echo "(1) already root"
else
    sudo -k # make sure to ask for password on next sudo
    if sudo true; then
        echo "(2) correct password"
    else
        echo "(3) wrong password"
        exit 1
    fi
fi

echo "Check dependencies..."

sudo ./build_env/prepare_scripts/install_requirements.sh
sudo ./build_env/prepare_scripts/version_check.sh
