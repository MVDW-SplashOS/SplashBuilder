echo "test partition set: ${splash_partition_root:?}"


mkdir -p $splash_partition_root/sources
chmod -v a+wt $splash_partition_root/sources

# Include and parse yaml script
export yaml_file=./config.yml
export yaml_prefix="config_"
source ./build_scripts/parse_yaml.sh
create_variables 


# downloading all required tools
for TOOL in ${config_tools_enabled_[*]}; do
	eval "TOOL_VERSION=\${config_tools_list__${TOOL}__version}"
	eval "TOOL_URL=\${config_tools_list__${TOOL}__url/\{VERSION\}/"$TOOL_VERSION"}"
	eval "TOOL_URL=\${TOOL_URL/\{VERSION\}/"$TOOL_VERSION"}" # if there is a 2nd version string in the url(too lazy for a propper fix)
	eval "TOOL_PATCH=\${config_tools_list__${TOOL}__patch/\{VERSION\}/"$TOOL_VERSION"}"
	eval "TOOL_MD5=\${config_tools_list__${TOOL}__checksum}"
	#echo "$TOOL:" 
	#echo "  - version: $TOOL_VERSION"
	#echo "  - url: $TOOL_URL"
	
	bn=$(basename $TOOL_URL)
	
	if ! test -f ./sources/$bn ; then
		wget $TOOL_URL -O ./sources/$bn
	else
		echo "$TOOL($TOOL_VERSION) already downloaded"
	fi
	
	if [[ $(md5sum "./sources/$bn") = $TOOL_MD5* ]] ; then
		echo "Checksum vailid"
	else
		echo "Error: Checksum of $TOOL not vailid."
		exit
	fi
	
	
	
	if ! [ $TOOL_PATCH == "false" ]; then
		bnp=$(basename $TOOL_PATCH)
		if ! test -f ./sources/$bnp ; then
			wget $TOOL_PATCH -O ./sources/$bnp
		else
			echo "Patch for $TOOL($TOOL_VERSION) already downloaded"
		fi
	fi
	
done

