
printf $UBlue
#printf "${1/""/"_"}" 
printf "Setup bash profile? [y/N]"
printf $White 
printf " "
read choice

case "$choice" in 
	y|Y )
		printf "Continueing operation...\n\n"
		
		cat > ~/.bash_profile <<-EOF
				exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash 
		EOF
		
		
		cat > ~/.bashrc <<-EOF
		set +h
		umask 022
		splash_partition_root=$splash_partition_root
		LC_ALL=POSIX
		SPLASHOS_TGT=$(uname -m)-lfs-linux-gnu
		PATH=/usr/bin
		if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
		PATH=$splash_partition_root/tools/bin:$PATH
		CONFIG_SITE=$splash_partition_root/usr/share/config.site
		export splash_partition_root LC_ALL SPLASHOS_TGT PATH CONFIG_SITE
		EOF
		
		
		[ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE;;
	* )
		printf "Skipping...\n\n" 

esac

MAKEFLAGS="-j$(nproc)"
echo "infile makeflag: ${MAKEFLAGS}"
