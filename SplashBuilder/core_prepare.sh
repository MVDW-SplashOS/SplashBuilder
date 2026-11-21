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

# No recursive chmod of the build tree. run.sh requires root and every build
# step runs as root, so nothing needs the tree to be world-writable. The old
# `chmod -R 777` ran on every run.sh invocation (recover included) and
# stripped setuid bits (dbus-daemon-launch-helper, polkit-agent-helper-1, su,
# passwd), made /etc/shadow world-readable and /etc, /usr, /var
# world-writable, which breaks polkit, GDM logins and bus activation.
# Only the build root itself needs to be enterable.
chmod 755 "$splash_partition_root"
