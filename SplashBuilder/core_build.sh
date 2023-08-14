#!/bin/bash

# 
# SplashOS Builder
#
# ----------------
#
# This tool is made to create a full SplashOS install.
#  



export DIST_ROOT=$(pwd)


source ./SplashBuilder/utils/reset_enviroment.sh

source ./SplashBuilder/utils/builder.sh

build

