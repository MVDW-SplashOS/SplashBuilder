#!/bin/bash

# 
# SplashOS Builder
#
# ----------------
#
# This tool is made to create a full SplashOS install.
#  



export DIST_ROOT=$(pwd)

# All steps required to build SplashOS:
# 
#
#
# Step 2:
#     |
#


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


# -------------------------------------------------------------
#
#      STEP 3: Cross Compiling Temporary Tools
#
# -------------------------------------------------------------

source SplashBuilder/build/m4.sh "m4-${config_tools_list__m4__version}.tar.xz"
source SplashBuilder/build/ncurses.sh "ncurses-${config_tools_list__ncurses__version}.tar.xz"
source SplashBuilder/build/bash.sh "bash-${config_tools_list__bash__version}.tar.xz"
source SplashBuilder/build/coreutils.sh "coreutils-${config_tools_list__coreutils__version}.tar.xz"
source SplashBuilder/build/diffutils.sh "diffutils-${config_tools_list__diffutils__version}.tar.xz"
source SplashBuilder/build/file.sh "file-${config_tools_list__file__version}.tar.xz"
source SplashBuilder/build/findutils.sh "findutils-${config_tools_list__findutils__version}.tar.xz"
source SplashBuilder/build/gawk.sh "gawk-${config_tools_list__gawk__version}.tar.xz"
source SplashBuilder/build/grep.sh "grep-${config_tools_list__grep__version}.tar.xz"
source SplashBuilder/build/gzip.sh "gzip-${config_tools_list__gzip__version}.tar.xz"
source SplashBuilder/build/make.sh "make-${config_tools_list__make__version}.tar.xz"
source SplashBuilder/build/patch.sh "patch-${config_tools_list__patch__version}.tar.xz"
source SplashBuilder/build/sed.sh "sed-${config_tools_list__sed__version}.tar.xz"
source SplashBuilder/build/tar.sh "tar-${config_tools_list__tar__version}.tar.xz"
source SplashBuilder/build/xz.sh "xz-${config_tools_list__xz__version}.tar.xz"
source SplashBuilder/build/binutils-pass-2.sh "binutils-${config_tools_list__binutils__version}.tar.xz"
source SplashBuilder/build/gcc-pass-2.sh "gcc-${config_tools_list__gcc__version}.tar.xz"

