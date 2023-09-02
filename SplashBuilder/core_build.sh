#!/bin/bash

# 
# SplashOS Builder
#
# ----------------
#
# This tool is made to create a full SplashOS install.
#  



export DIST_ROOT=$(pwd)


source ./SplashBuilder/utils/reset_enviroment.sh

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
	cp -r ./config.yml $splash_partition_root
	cp -r ./edition-sources.yml $splash_partition_root
	cp -r ./SplashBuilder/core_build.sh $splash_partition_root
	
	cp -r ./sources $splash_partition_root
	
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
	./core_build.sh env_chroot
EOF
}



if [ "$1" = "env_chroot" ]; then
	build_data=$(yq eval ".build[${builder_currentstep}].build" "${DIST_ROOT}/edition-sources.yml")
else
	build_data=$(yq eval ".build" "${DIST_ROOT}/edition-sources.yml")
fi

build_count=$(echo "${build_data}" | yq eval ". | length")

echo "Start running build"

for (( i=0; i<build_count; ++i)); do

	builder_currentstep=$i;
	
	cleanup "${package}-${package_version}"

	task=$(echo "${build_data}" | yq eval ".[$i].task")

	
	if [ "$task" = "change_enviroment" ]; then
		enviroment=$(echo "${build_data}" | yq eval ".[$i].enviroment")
		echo "At the change enviroment step."
		
		if [ "$enviroment" = "chroot" ]; then
			task_chane_env
		else
			echo "Unknown enviroment type '${enviroment}', exiting.."
			exit
		fi
		
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
	
	



