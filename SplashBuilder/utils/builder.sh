
cleanup() {
	cd $DIST_ROOT/sources
	rm -rf manifest.yml
	rm -rf build
	rm -rf patch
	
	if [ -n "$1" ]; then
		rm -rf $1
	fi

}


build() {

	yq eval '.build[] | .task + " " + .package + " "+ .buildmode' "${DIST_ROOT}/edition-sources.yml" | while IFS= read -r build_info; do
		cleanup "${package}-${package_version}"

		task=$(echo "$build_info" | awk '{print $1}')
		
		if [ "$task" = "compile" ]; then
		
			package=$(echo "$build_info" | awk '{print $2}')
			buildmode=$(echo "$build_info" | awk '{print $3}')
			package_version=$(yq eval '.packages[] | select(.package == "'"$package"'") | .version' "${DIST_ROOT}/edition-sources.yml")


		
			task_compile $package $package_version $buildmode
		elif [ "$task" = "exit_buildloop" ]; then
			exit
		fi

	done
}

task_compile(){
	cd "$DIST_ROOT/sources"
	
	echo "tessst: ${package}-${package_version}.tar.xz"
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

