#!/bin/bash


echo "NAME=\"${config_release_name}\"
VERSION=\"${config_release_version} ${config_release_cycle}\"
ID=${config_release_name}
PRETTY_NAME=\"${config_release_name} ${config_release_version}\"
VERSION_CODENAME=\"${config_release_codename}\"" > /etc/os-release

echo "DISTRIB_ID=\"${config_release_name}\"
DISTRIB_RELEASE=\"${config_release_version} ${config_release_cycle}\"
DISTRIB_CODENAME=\"${config_release_codename}\"
DISTRIB_DESCRIPTION=\"${config_release_name}\"" > /etc/lsb-release


cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF
