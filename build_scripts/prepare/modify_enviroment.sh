# Modify enviroment to build SplashOS

mv $HOME/.bash_profile $HOME/.bash_profile.bak
mv $HOME/.bashrc $HOME/.bashrc.bak


cat > $HOME/.bash_profile  << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash 
EOF


cat > $HOME/.bashrc  << "EOF"
set +h
umask 022
splash_partition_root=/mnt/splashos
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
