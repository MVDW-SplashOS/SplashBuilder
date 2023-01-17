#!/bin/bash
sudo rm /bin/sh
sudo ln -s /bin/bash /bin/sh

if [ -x "$(command -v apt-get)" ]; then sudo apt-get install binutils bison gawk gcc g++ make patch texinfo libisl-dev -y
elif [ -x "$(command -v dnf)" ];     then sudo dnf install binutils bison gawk gcc g++ make patch texinfo -y
else echo "FAILED TO INSTALL PACKAGES: Package manager not found.">&2; fi
