echo "test partition set: ${splash_partition_root:?}"

mkdir -p ./sources
chmod -v a+wt ./sources


# Download sources
if [ $config_build_edition != "custom" ]; then
	wget -q https://www.enthix.net/SplashOS/downloads/configs/edition-packages/${config_release_version}/${config_build_edition}.yml -O ./edition-sources.yml
fi


download_tool() {
	rm -rf "./input/$bn"

	wget -q https://www.enthix.net/SplashOS/downloads/source-packages/${package}/${package}-${version}.tar.xz -O ./sources/${package}-${version}.tar.xz
	echo_ok "Downloaded package \e[1;37m${package}($version)\e[0m Successfully."
}


yq eval '.packages[] | .package + " " + .version' "./edition-sources.yml" | while IFS= read -r package_info; do
    package=$(echo "$package_info" | awk '{print $1}')
    version=$(echo "$package_info" | awk '{print $2}')
    
    if ! test -f ./sources/${package}-${version}.tar.xz; then
    	download_tool $package $version
    fi
done

