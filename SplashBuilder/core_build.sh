#!/bin/bash

# 
# SplashOS Builder
#
# ----------------
#
# This tool is made to create a full SplashOS install.
#  

echo "RUNNING BUILD SCRIPT"

set -e
export DIST_ROOT=$(pwd)


export MAKEFLAGS="-j$(nproc)"

cleanup() {
	cd $DIST_ROOT/sources
	rm -rf manifest.yml
	rm -rf build
	rm -rf patch
	
	if [ -n "$1" ]; then
		rm -rf $1
	fi

}


task_compile(){
	cd "$DIST_ROOT/sources"

	tar --overwrite -xvf "${package}-${package_version}.tar.xz"

	echo "-------------------------------------------------------"
	echo "Processing ${package}(step: ${buildmode})"
	echo "-------------------------------------------------------"
	sleep 1

	
	cd "${package}-${package_version}"


	package_build_file=$(yq eval ".build.${buildmode}.script" "${DIST_ROOT}/sources/manifest.yml")
	
	source "../build/${package_build_file}"

	cleanup "${package}-${package_version}"
}

task_chane_env(){
	cp -r $DIST_ROOT/config.yml $splash_partition_root
	cp -r $DIST_ROOT/edition-sources.yml $splash_partition_root
	cp -r $DIST_ROOT/SplashBuilder/core_build.sh $splash_partition_root
	
	cp -r $DIST_ROOT/sources $splash_partition_root
	
	# Change Ownership
	chown -R root:root $splash_partition_root/{usr,lib,var,etc,bin,sbin,tools,lib64}

	# Preparing Virtual Kernel File System
	mkdir -pv $splash_partition_root/{dev,proc,sys,run}

	mount -v --bind /dev $splash_partition_root/dev

	mount -v --bind /dev/pts $splash_partition_root/dev/pts
	mount -vt proc proc $splash_partition_root/proc
	mount -vt sysfs sysfs $splash_partition_root/sys
	mount -vt tmpfs tmpfs $splash_partition_root/run


	if [ -h $splash_partition_root/dev/shm ]; then
	  mkdir -pv $splash_partition_root/$(readlink $splash_partition_root/dev/shm)
	else
	  mount -t tmpfs -o nosuid,nodev tmpfs $splash_partition_root/dev/shm
	fi
	
cat << EOF | sudo chroot "$splash_partition_root" /usr/bin/env -i HOME=/root TERM="$TERM" PS1='(splash chroot) \u:\w\$ ' PATH=/usr/bin:/usr/sbin /bin/bash --login
	echo "Builder Current Step:"
	echo $i
	./core_build.sh env_chroot $i
EOF
}



task_setup_chroot(){

	# Creating Directories
	mkdir -pv /{boot,home,mnt,opt,srv}

	mkdir -pv /etc/{opt,sysconfig}
	mkdir -pv /lib/firmware
	mkdir -pv /media/{floppy,cdrom}
	mkdir -pv /usr/{,local/}{include,src}
	mkdir -pv /usr/local/{bin,lib,sbin}
	mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
	mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
	mkdir -pv /usr/{,local/}share/man/man{1..8}
	mkdir -pv /var/{cache,local,log,mail,opt,spool}
	mkdir -pv /var/lib/{color,misc,locate}

	ln -sfv /run /var/run
	ln -sfv /run/lock /var/lock

	install -dv -m 0750 /root
	install -dv -m 1777 /tmp /var/tmp


	# Creating Essential Files and Symlinks
	ln -sfv /proc/self/mounts /etc/mtab

cat > /etc/hosts << EOF
127.0.0.1  localhost $(hostname)
::1        localhost
EOF

cat > /etc/passwd << EOF
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
systemd-journal-gateway:x:73:73:systemd Journal Gateway:/:/usr/bin/false
systemd-journal-remote:x:74:74:systemd Journal Remote:/:/usr/bin/false
systemd-journal-upload:x:75:75:systemd Journal Upload:/:/usr/bin/false
systemd-network:x:76:76:systemd Network Management:/:/usr/bin/false
systemd-resolve:x:77:77:systemd Resolver:/:/usr/bin/false
systemd-timesync:x:78:78:systemd Time Synchronization:/:/usr/bin/false
systemd-coredump:x:79:79:systemd Core Dumper:/:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
systemd-oom:x:81:81:systemd Out Of Memory Daemon:/:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF

cat > /etc/group << EOF
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
systemd-journal:x:23:
input:x:24:
mail:x:34:
kvm:x:61:
systemd-journal-gateway:x:73:
systemd-journal-remote:x:74:
systemd-journal-upload:x:75:
systemd-network:x:76:
systemd-resolve:x:77:
systemd-timesync:x:78:
systemd-coredump:x:79:
uuidd:x:80:
systemd-oom:x:81:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF

	touch /var/log/{btmp,lastlog,faillog,wtmp}
	chgrp -v utmp /var/log/lastlog
	chmod -v 664  /var/log/lastlog
	chmod -v 600  /var/log/btmp

	#reset enviroment
	find /sources -maxdepth 1 -mindepth 1 -type d -exec rm -rf '{}' \;

}

[ "$1" != "env_chroot" ] && start_pos=0 || start_pos=$2

# Get build data from build configuration file
if [ "$1" != "env_chroot" ]; then
	build_data=$(yq eval ".build" "${DIST_ROOT}/edition-sources.yml")
else
	build_data=$(yq eval ".build[${start_pos}].build" "/edition-sources.yml")
fi

build_count=$(echo "${build_data}" | yq eval ". | length")
	
# Run Build
for (( i=0; i<build_count; ++i)); do
	echo "running loop";
	
	# Cleanup the temporarily files
	cleanup "${package}-${package_version}"

	# Get spesific task
	task=$(echo "${build_data}" | yq eval ".[$i].task")

	echo "TASK: $task"

	if [ "$task" = "change_enviroment" ]; then
		enviroment=$(echo "${build_data}" | yq eval ".[$i].enviroment")
		echo "At the change enviroment step."
		
		if [ "$enviroment" = "chroot" ]; then
			task_chane_env
		else
			echo "Unknown enviroment type '${enviroment}', exiting.."
			exit
		fi
	elif [ "$task" = "setup_chroot" ]; then
		task_setup_chroot

	elif [ "$task" = "compile" ]; then
	
		package=$(echo "${build_data}" | yq eval ".[$i].package")
		buildmode=$(echo "${build_data}" | yq eval ".[$i].buildmode")
		package_version=$(yq eval '.packages[] | select(.package == "'"$package"'") | .version' "${DIST_ROOT}/edition-sources.yml")
	
		task_compile $package $package_version $buildmode
	else
		echo "Unknown task type '${task}', exiting.."
		exit
	
	fi

done
	
	



