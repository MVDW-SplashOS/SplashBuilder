dbhome=$(eval echo "~splashbuilder")


if ! test $(id -u splashbuilder) ; then

[ ! -e /home/splashbuilder ] || rm -rf /home/splashbuilder 

groupadd splashbuilder
useradd -s /bin/bash -g splashbuilder -m -k /dev/null splashbuilder
passwd splashbuilder #TODO: Set the default password in the config file.


echo "splashbuilder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoers_distbuild



cat > $dbhome/.bash_profile  << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash 
EOF




fi


cat > $dbhome/.bashrc  << "EOF"
set +h
umask 022
splash_partition_root=/home/mvdw/Documents/GitHub/SplashOS/splashos
LC_ALL=POSIX
SPLASHOS_TGT=$(uname -m)-splash-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$splash_partition_root/tools/bin:$PATH
CONFIG_SITE=$splash_partition_root/usr/share/config.site
MAKEFLAGS="-j$(nproc)"
export splash_partition_root LC_ALL SPLASHOS_TGT PATH CONFIG_SITE MAKEFLAGS
EOF




[ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE;



chown -v splashbuilder $splash_partition_root/{usr{,/*},lib,var,etc,bin,sbin,tools,lib64}
chown -v splashbuilder ./sources


echo "Done!" 
