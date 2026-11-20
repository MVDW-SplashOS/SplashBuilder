echo "test partition set: ${splash_partition_root:?}"

mkdir -p ./sources
chmod -v a+wt ./sources


# Cache-busting seed: one per run. syspkg sits behind Cloudflare, which can
# serve stale tarballs (stale body AND stale Last-Modified) for a long time.
# Appending ?seed=<timestamp> makes every request a fresh URL -> CDN cache
# miss -> the origin's truthful headers/body. wget -N cannot be combined with
# a changing URL (each seed is a "new" file to it), so the freshness decision
# is made explicitly with a HEAD request instead. Disable with
# download_cachebust: false in config.yml.
SEED=$(date +%s)
if [ "${config_download_cachebust:-true}" = "false" ]; then
	cachebust=false
else
	cachebust=true
fi

# Download sources
if [ $config_build_edition != "custom" ]; then
	fetch_edition_config() {
		# $1 = edition name, $2 = destination file
		local url="https://syspkg.splashos.com/configs/edition-packages/${config_release_version}/${1}.yml"
		$cachebust && url="${url}?seed=${SEED}"
		wget -q "$url" -O "$2"
	}

	edition_url="https://syspkg.splashos.com/configs/edition-packages/${config_release_version}/${config_build_edition}.yml"
	$cachebust && edition_url="${edition_url}?seed=${SEED}"
	if ! wget -q "$edition_url" -O ./edition-sources.yml; then
		echo_fail "Failed to fetch edition config '\e[1;37m${config_build_edition}\e[0m' for release ${config_release_version} from syspkg (does edition-packages/${config_release_version}/${config_build_edition}.yml exist?)."
		exit 1
	fi
	# A 200 response can still be an error page / empty body; downstream yq
	# would fail with confusing errors on that, so check the shape up front.
	# A valid edition has its own package list and/or a parent to inherit
	# one from: leaf editions such as `desktop` only set parentconfig and
	# add build tasks, without a packages: key of their own.
	edition_shape_ok=false
	if [ -s ./edition-sources.yml ]; then
		if grep -q '^packages:' ./edition-sources.yml; then
			edition_shape_ok=true
		elif grep -qE '^parentconfig: *[A-Za-z0-9_"-]' ./edition-sources.yml && \
		     ! grep -qE '^parentconfig: *"?false' ./edition-sources.yml; then
			edition_shape_ok=true
		fi
	fi
	if [ "$edition_shape_ok" != true ]; then
		echo_fail "Fetched edition config '\e[1;37m${config_build_edition}\e[0m' is empty or malformed."
		exit 1
	fi

	# Edition configs can chain via parentconfig (molecule <- distro <-
	# server/workstation). Flatten the chain into one task list before
	# anything reads edition-sources.yml (see the resolver for details).
	source ./SplashBuilder/utils/resolve_parentconfig.sh
	resolve_parentconfig "$config_build_edition"

	# After flattening, the build needs a package list to download.
	if [ "$(yq eval '.packages | length' ./edition-sources.yml 2>/dev/null)" = "0" ] || \
	   [ -z "$(yq eval '.packages | length' ./edition-sources.yml 2>/dev/null)" ]; then
		echo_fail "Edition '\e[1;37m${config_build_edition}\e[0m' has no packages after resolving its parentconfig chain."
		exit 1
	fi
fi


download_tool() {
	local url="https://syspkg.splashos.com/source-packages/${package}/${package}-${version}.tar.xz"
	local dest="./sources/${package}-${version}.tar.xz"
	$cachebust && url="${url}?seed=${SEED}"

	# Skip the body transfer when the origin copy is not newer than the
	# cached one (HEAD on the seeded URL returns truthful headers)
	if test -f "$dest"; then
		lm=$(curl -sI --max-time 30 "$url" | sed -n 's/^[Ll]ast-[Mm]odified: //p' | tr -d '\r')
		remote_ts=$(date -d "$lm" +%s 2>/dev/null || echo 0)
		if [ "$remote_ts" -gt 0 ] && [ "$remote_ts" -le "$(stat -c %Y "$dest")" ]; then
			echo_ok "Package \e[1;37m${package}($version)\e[0m is up to date."
			return 0
		fi
	fi

	# .part then rename so a failed download never leaves a broken tarball
	wget -q "$url" -O "${dest}.part" && mv "${dest}.part" "$dest"
	if test -f "$dest"; then
		echo_ok "Fetched package \e[1;37m${package}($version)\e[0m Successfully."
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
