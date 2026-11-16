# ---------------------------------------------------------------------------
# parentconfig chain resolution
#
# Edition configs can inherit from a parent config:
#
#   molecule (minimal base) <- distro (systemd, dracut, boot config)
#                           <- server / workstation (edition-specific tasks)
#
# The build engine (core_build.sh) only understands a single flat task list,
# so the chain is resolved HERE, at fetch time, into one flat
# edition-sources.yml:
#
#   - the root parent's build list runs first, the child's is appended
#   - the package lists are merged; on a duplicate package name the child's
#     pin wins (a child re-pinning a version is more specific)
#   - the output has parentconfig: false, so the flat file is inert
#
# Because the flat file is also what task_chane_env copies into the chroot,
# the chroot phase sees the exact same task indexes as the host phase and
# all checkpoint/recover bookkeeping works unchanged.
#
# The resolver needs:
#   fetch_edition_config <name> <dest>  - defined by the caller (wget in
#                                         dependencies.sh, overridden in tests)
#   yq                                  - mikefarah v4 (used by the build anyway)
#   echo_ok / echo_fail                 - SplashBuilder echo helpers
# ---------------------------------------------------------------------------

resolve_parentconfig() {
	local edition_name="${1}"
	local flat="./edition-sources.yml"

	local parent
	parent=$(yq eval '.parentconfig // ""' "$flat")

	# parentconfig: false / "" means "no parent, nothing to do"
	if [ -z "$parent" ] || [ "$parent" = "false" ]; then
		return 0
	fi

	echo_ok "Resolving parentconfig chain for \e[1;37m${edition_name}\e[0m..."

	# Walk the chain from the child up to the root, fetching every config.
	# chain[] collects child->root; a cycle or an unfetchable parent aborts.
	local -a chain=()
	local -A seen=()
	while [ -n "$parent" ] && [ "$parent" != "false" ]; do
		if [ -n "${seen[$parent]:-}" ]; then
			echo_fail "parentconfig cycle detected at '$parent', aborting."
			exit 1
		fi
		seen[$parent]=1
		chain+=("$parent")
		local pfile="./.parentconfig-${parent}.yml"
		fetch_edition_config "$parent" "$pfile" || {
			echo_fail "Failed to fetch parent config '${parent}'."
			exit 1
		}
		if [ ! -s "$pfile" ]; then
			echo_fail "Parent config '${parent}' was empty (does it exist on syspkg?)."
			exit 1
		fi
		parent=$(yq eval '.parentconfig // ""' "$pfile")
	done

	# Flatten root -> child (reverse of the collection order): start from the
	# root parent and successively append the next config's build list and
	# merge its package pins (child wins on duplicates).
	local -a files=()
	local idx
	for (( idx=${#chain[@]}-1; idx>=0; idx-- )); do
		files+=("./.parentconfig-${chain[$idx]}.yml")
	done

	# The child's own config is the LAST element of the merge sequence: root
	# parents first, the child's tasks/pins appended at the very end.
	cp "$flat" "./.parentconfig-${edition_name}.yml"
	files+=("./.parentconfig-${edition_name}.yml")

	local flat_file f tmp
	flat_file="${files[0]}"
	for f in "${files[@]:1}"; do
		tmp="./.parentconfig-merged.yml"
		yq eval-all '
			select(fi == 0) as $acc |
			select(fi == 1) as $next |
			{
				"parentconfig": false,
				"packages": (($next.packages // []) + ($acc.packages // [])) | unique_by(.package),
				"build": (($acc.build // []) + ($next.build // []))
			}
		' "$flat_file" "$f" > "$tmp" || {
			echo_fail "Failed to merge parentconfig chain at '$f'."
			exit 1
		}
		mv "$tmp" "$flat_file"
	done

	mv "$flat_file" "$flat"
	rm -f ./.parentconfig-*.yml

	echo_ok "Edition chain flattened: \e[1;37m${chain[*]} -> ${edition_name}\e[0m (root tasks first)."
}
