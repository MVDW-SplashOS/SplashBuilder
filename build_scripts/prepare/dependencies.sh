echo "test partition set: ${splash_partition_root:?}"

mkdir -p ./sources
chmod -v a+wt ./sources

export DOWNLOAD_RETRYS=0
export DOWNLOAD_RETRYS_MAX=3


# Download sources
wget -q https://www.enthix.net/SplashOS/downloads/configs/edition-packages/${config_release_version}/${config_build_edition}.yml -O ./edition-sources.yml
export yaml_file=./edition-sources.yml
export yaml_prefix="config_"
source ./build_scripts/utils/parse_yaml.sh
create_variables 



download_tool() {
	rm -rf "./input/$bn"
	wget -q https://www.enthix.net/SplashOS/downloads/source-packages/${TOOL}/${TOOL}-${TOOL_VERSION}.tar.xz -O ./sources/${TOOL}-${TOOL_VERSION}.tar.xz
	echo_ok "Downloaded package \e[1;37m${TOOL}\e[0m Successfully."
}

# TODO: add md5 after patch support
check_tool() {
	if [[ $(md5sum "./input/$bn") != $TOOL_MD5* ]]; then

		((DOWNLOAD_RETRYS = DOWNLOAD_RETRYS + 1))

		if [ $DOWNLOAD_RETRYS != $DOWNLOAD_RETRYS_MAX ]; then
			echo_warn "Checksum of package \e[1;37m${TOOL}\e[0m does not match, retrying (${DOWNLOAD_RETRYS}/${DOWNLOAD_RETRYS_MAX})"
			download_tool $TOOL $TOOL_URL $bn
		else
			echo_fail "Checksum of package ${TOOL} does not match and reached the maximum retries."
			exit
		fi
	fi

}

# downloading all required tools
for TOOL in ${config_tools_enabled_[*]}; do
	eval "TOOL_VERSION=\${config_tools_list__${TOOL}__version}"
	eval "TOOL_URL=\${config_tools_list__${TOOL}__url/\{VERSION\}/"$TOOL_VERSION"}"
	eval "TOOL_URL=\${TOOL_URL/\{VERSION\}/"$TOOL_VERSION"}" # if there is a 2nd version string in the url(too lazy for a propper fix)
	eval "TOOL_PATCH=\${config_tools_list__${TOOL}__patch/\{VERSION\}/"$TOOL_VERSION"}"
	eval "TOOL_MD5=\${config_tools_list__${TOOL}__checksum}"


	if ! test -f ./sources/${TOOL}-${TOOL_VERSION}.tar.xz; then
		download_tool $TOOL $TOOL_VERSION
	fi

done
