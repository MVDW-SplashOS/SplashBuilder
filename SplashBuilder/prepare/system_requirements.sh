#!/bin/sh

# 
# SplashOS Builder - System Requirements Script
#
# ----------------
#
# This script is for checking, installing and configuring the host system.
# Based on the version-check script from LFS but modified to also install and configure when needed.

# 
echo "Checking host system configuration... "


# Step 1.1 - Check bash
MYSH=$(readlink -f /bin/sh)
if grep -q bash $MYSH 
then
	echo "Bash [OK]"
else
	
	rm /bin/sh
	ln -s /bin/bash /bin/sh
	echo "ERROR2: /bin/sh does not point to bash"

fi
unset MYSH

# TODO: install when needed, do more checks

# 
if [ -x "$(command -v apt-get)" ]; then
	# From the package manager
	sudo apt remove golang # needs to be removed because debian only ships an older version
	sudo apt install binutils bison gawk gcc g++ make patch texinfo libisl-dev wget -y
	
	# Install go lang
	#rm -rf /usr/local/go
	#tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
	
	
elif [ -x "$(command -v dnf)" ]; then
	sudo dnf install binutils bison gawk gcc g++ make patch texinfo -y
else
	echo "FAILED TO INSTALL PACKAGES: Package manager not found.">&2;
fi

if ! [ -f "/usr/bin/yq" ]; then
	wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
	chmod +x /usr/bin/yq
fi



echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-
bison --version | head -n1

if [ -h /usr/bin/yacc ]; then
  echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`";
elif [ -x /usr/bin/yacc ]; then
  echo yacc is `/usr/bin/yacc --version | head -n1`
else
  echo "yacc not found"
fi

echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2
diff --version | head -n1
find --version | head -n1
gawk --version | head -n1

if [ -h /usr/bin/awk ]; then
  echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`";
elif [ -x /usr/bin/awk ]; then
  echo awk is `/usr/bin/awk --version | head -n1`
else
  echo "awk not found"
fi

gcc --version | head -n1
g++ --version | head -n1
grep --version | head -n1
gzip --version | head -n1
cat /proc/version
m4 --version | head -n1
make --version | head -n1
patch --version | head -n1
echo Perl `perl -V:version`
python3 --version
sed --version | head -n1
tar --version | head -n1
makeinfo --version | head -n1  # texinfo version
xz --version | head -n1

echo 'int main(){}' > dummy.c && g++ -o dummy dummy.c
if [ -x dummy ]
  then echo "g++ compilation OK";
  else echo "g++ compilation failed"; fi
rm -f dummy.c dummy















