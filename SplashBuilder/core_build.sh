#!/bin/bash

# 
# SplashOS Builder
#
# ----------------
#
# This tool is made to create a full SplashOS install.
#  



export DIST_ROOT=$(pwd)
export builder_currentstep=0
export builder_currentstep_env=0

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


build_data=$(yq eval '.build' "${DIST_ROOT}/edition-sources.yml")
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
			echo "TODO: Going in the chroot"
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
	
	



