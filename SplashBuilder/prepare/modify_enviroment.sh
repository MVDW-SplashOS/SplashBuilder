# Modify enviroment to build SplashOS

# Guarded moves: on a re-run the originals were already moved away by a
# previous build (a plain mv aborts the whole build via set -e). -bv keeps
# the older .bak instead of destroying it when one already exists.
[ ! -e $HOME/.bash_profile ] || mv -bv $HOME/.bash_profile $HOME/.bash_profile.bak
[ ! -e $HOME/.bashrc ] || mv -bv $HOME/.bashrc $HOME/.bashrc.bak


cat > $HOME/.bash_profile  << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash 
EOF


# Unquoted EOF so the CURRENT build root (from config.yml, set by run.sh /
# partitions.sh) is baked into the file; $ signs that must stay literal for
# the generated shell code are escaped.
cat > $HOME/.bashrc  << EOF
set +h
umask 022
splash_partition_root=$splash_partition_root
LC_ALL=POSIX
SPLASHOS_TGT=\$(uname -m)-splash-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:\$PATH; fi
PATH=\$splash_partition_root/tools/bin:\$PATH
PATH=/usr/local/go/bin:\$PATH
CONFIG_SITE=\$splash_partition_root/usr/share/config.site
MAKEFLAGS="-j\$(nproc)"
export splash_partition_root LC_ALL SPLASHOS_TGT PATH CONFIG_SITE MAKEFLAGS
EOF

# Cross-compilation configure results (LFS 13.1, section 6.2). Without this
# file the referenced CONFIG_SITE is missing and cross builds fail with
# "cannot run test program while cross compiling" for checks that have no
# cross-compile fallback.
mkdir -pv $splash_partition_root/usr/share
cat > $splash_partition_root/usr/share/config.site << "EOF"
ac_cv_func_posix_spawn_file_actions_addchdir=yes
ac_cv_func_posix_spawn_file_actions_addfchdir=yes
EOF

[ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE;
