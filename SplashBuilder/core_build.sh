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


cleanup(){
	cd $DIST_ROOT/sources
	rm -rf manifest.yml
	rm -rf build
	rm -rf patch
	
	if [ -n "$1" ]; then
		rm -rf $1
	fi

}

step_list=()
declare -A step_list_count

yq eval '.build[] | .package + " " + .buildmode' "${DIST_ROOT}/edition-sources.yml" | while IFS= read -r build_info; do

	cleanup "${package}-${package_version}"

	

	package=$(echo "$build_info" | awk '{print $1}')
	buildmode=$(echo "$build_info" | awk '{print $2}')
	package_version=$(yq eval '.packages[] | select(.package == "'"$package"'") | .version' "${DIST_ROOT}/edition-sources.yml")

	step_list+=($package)


	cd $DIST_ROOT/sources
	tar --overwrite -xvf "${package}-${package_version}.tar.xz"


	if [[ -z "${step_list_count[$package]}" ]]; then
		step_list_count[$package]=1
	else
		((step_list_count[$package]++))
	fi
		
	
	echo "-------------------------------------------------------"
	echo "Processing ${package}(step: ${step_list_count[$package]})"
	echo "-------------------------------------------------------"
	sleep 1

	package_build_file=$(yq eval ".build.${step_list_count[$package]}.script" "${DIST_ROOT}/sources/manifest.yml")
	cd "${package}-${package_version}"


	source ../build/${package_build_file}

	cleanup "${package}-${package_version}"
    

done

