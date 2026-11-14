echo "test partition set: ${splash_partition_root:?}"

mkdir -p ./sources
chmod -v a+wt ./sources


# Download sources
if [ $config_build_edition != "custom" ]; then
	wget -q https://syspkg.splashos.com/configs/edition-packages/${config_release_version}/${config_build_edition}.yml -O ./edition-sources.yml
fi


download_tool() {
	rm -rf "./input/$bn"

	# -N (timestamping) re-downloads a package whenever the copy on syspkg is
	# newer than the cached one, so repacked/updated packages propagate
	# automatically. NOTE: syspkg sits behind Cloudflare — if a repacked
	# package seems to never arrive, the CDN edge is serving a stale copy
	# (body AND Last-Modified), which defeats -N. Purge the Cloudflare cache
	# for /source-packages/* after publishing, or set short/no cache TTL.
	wget -N -q https://syspkg.splashos.com/source-packages/${package}/${package}-${version}.tar.xz -P ./sources
	if test -f ./sources/${package}-${version}.tar.xz; then
		echo_ok "Fetched/verified package \e[1;37m${package}($version)\e[0m Successfully."
	else
		echo_fail "Failed to download package \e[1;37m${package}($version)\e[0m."
		exit 1
	fi
}


yq eval '.packages[] | .package + " " + .version' "./edition-sources.yml" | while IFS= read -r package_info; do
    package=$(echo "$package_info" | awk '{print $1}')
    version=$(echo "$package_info" | awk '{print $2}')

    download_tool $package $version
done
