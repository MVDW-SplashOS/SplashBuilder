echo "Dist Root: ${DIST_ROOT:?}"
echo "LFS: ${LFS:?}"

mkdir -p $DIST_ROOT/build_env/sources


# Include and parse yaml script
export yaml_file=$DIST_ROOT/build_env/config.yml
export yaml_prefix="config_"
source $DIST_ROOT/build_env/build_scripts/includes/parse_yaml.sh
create_variables 


# downloading all required tools
for TOOL in ${config_tools_enabled_[*]}; do
	eval "TOOL_VERSION=\${config_tools_list__${TOOL}__version}"
	eval "TOOL_URL=\${config_tools_list__${TOOL}__url/\{VERSION\}/"$TOOL_VERSION"}"
	eval "TOOL_URL=\${TOOL_URL/\{VERSION\}/"$TOOL_VERSION"}" # if there is a 2nd version string in the url(too lazy for a propper fix)
	eval "TOOL_PATCH=\${config_tools_list__${TOOL}__patch/\{VERSION\}/"$TOOL_VERSION"}"
	eval "TOOL_MD5=\${config_tools_list__${TOOL}__checksum}"
	#echo "$TOOL:" 
	#echo "  - version: $TOOL_VERSION"
	#echo "  - url: $TOOL_URL"
	
	bn=$(basename $TOOL_URL)
	
	if ! test -f $DIST_ROOT/build_env/sources/$bn ; then
		wget $TOOL_URL -O $DIST_ROOT/build_env/sources/$bn
	else
		echo "$TOOL($TOOL_VERSION) already downloaded"
	fi
	
	if [[ $(md5sum "$DIST_ROOT/build_env/sources/$bn") = $TOOL_MD5* ]] ; then
		echo "Checksum vailid"
	else
		echo "Error: Checksum of $TOOL not vailid."
		exit
	fi
	
	
	
	if ! [ $TOOL_PATCH == "false" ]; then
		bnp=$(basename $TOOL_PATCH)
		if ! test -f $DIST_ROOT/build_env/sources/$bnp ; then
			wget $TOOL_PATCH -O $DIST_ROOT/build_env/sources/$bnp
		else
			echo "Patch for $TOOL($TOOL_VERSION) already downloaded"
		fi
	fi
	
done


mkdir -pv $LFS/{bin,etc,lib,sbin,usr,var,lib64,tools}

if ! test $(id -u distbuild) ; then

groupadd distbuild
useradd -s /bin/bash -g distbuild -m -k /dev/null distbuild
passwd distbuild
chown -v distbuild $LFS/{usr,lib,var,etc,bin,sbin,tools,lib64,sources}

echo "distbuild ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoers_distbuild

dbhome=$(eval echo "~distbuild")

cat > $dbhome/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > $dbhome/.bashrc << EOF
set +h
umask 022
LFS=$LFS
export DIST_ROOT=$DIST_ROOT
EOF

cat >> $dbhome/.bashrc << "EOF"
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS="-j$(nproc)"
EOF


fi


echo "Done!" 
