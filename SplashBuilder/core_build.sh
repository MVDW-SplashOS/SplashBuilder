#!/bin/bash

# 
# SplashOS Builder
#
# ----------------
#
# This tool is made to create a full SplashOS install.
#  

echo "RUNNING BUILD SCRIPT"

set -e
# pipefail: task output is piped through `tee` for logging; without this a
# failing recipe would hide behind tee's success status.
set -o pipefail
export DIST_ROOT=$(pwd)

# Build environment
# These are normally set in ~/.bashrc (see prepare/modify_enviroment.sh), but
# that file is only sourced by *interactive* shells, so scripts run with sudo
# or from the chroot do not have them. If SPLASHOS_TGT is empty, GCC's
# configure treats the build as native and fails with:
#   "bootstrapping with --disable-libstdcxx is not supported"
: "${splash_partition_root:=/mnt/splashos}"
: "${SPLASHOS_TGT:=$(uname -m)-splash-linux-gnu}"
export splash_partition_root SPLASHOS_TGT

# Make sure the cross toolchain is findable. Unconditional on purpose: a
# nonexistent dir on PATH is harmless, and on a FRESH build tools/ is empty
# at this point — gcc pass1 installs the cross-gcc into it and its recipe
# immediately invokes $SPLASHOS_TGT-gcc (limits.h step). With the old
# [ -x tools/bin/gcc ] gate the prepend never fired on fresh builds and
# gcc pass1 failed with "command not found".
case ":$PATH:" in
	*":$splash_partition_root/tools/bin:"*) ;;
	*) export PATH="$splash_partition_root/tools/bin:$PATH" ;;
esac

# One make job per core, but no more than memory allows: the heaviest
# C++ units (gcc's gimple-match-*.cc / insn-*.cc, later mozjs and rust)
# need up to ~2 GiB each, and -j$(nproc) on a 12-core/16 GiB machine with
# no active swap got gcc pass 2 OOM-killed (make "Error 137"). Budget
# 2 GiB of RAM+swap per job. SPLASH_JOBS overrides the computed value.
splash_build_jobs() {
	local cores mem_kib jobs
	cores=$(nproc)
	mem_kib=$(awk '/^(MemTotal|SwapTotal):/ {sum += $2} END {print sum + 0}' /proc/meminfo 2>/dev/null)
	jobs=$cores
	if [ "${mem_kib:-0}" -gt 0 ]; then
		local mem_jobs=$(( mem_kib / (2 * 1024 * 1024) ))
		[ "$mem_jobs" -lt 1 ] && mem_jobs=1
		[ "$mem_jobs" -lt "$jobs" ] && jobs=$mem_jobs
	fi
	echo "${SPLASH_JOBS:-$jobs}"
}
export MAKEFLAGS="-j$(splash_build_jobs)"

join_path() {
   base_path=${1}
   sub_path=${2}
   full_path="${base_path:+$base_path/}$sub_path"
   full_path=$(realpath ${full_path})
   echo $full_path
}


# ---------------------------------------------------------------------------
# Build logging
#
#   $splash_partition_root/.build_logs/index.log                     one line per task/run
#   $splash_partition_root/.build_logs/<pkg>-<ver>-<mode>-<ts>.log   full task output
#
# The dot-prefixed directory survives `rm -rf $splash_partition_root/*`
# (reset_enviroment.sh), and resolves to the same directory in the host phase
# ($splash_partition_root/.build_logs) and the chroot phase (/.build_logs,
# because the chroot env passes splash_partition_root=/).
#
# Opt-in recipe tracing: run the build with SPLASHBUILDER_DEBUG=1 to add
# `set -x` to the recipe shell (very verbose, goes to the task log only).
# ---------------------------------------------------------------------------
build_log_dir() {
	join_path "${splash_partition_root:-/}" .build_logs
}

log_run_start() {
	local log_dir
	log_dir=$(build_log_dir)
	mkdir -p "$log_dir" 2>/dev/null || true
	echo "[run] start $(date -Ins) mode=${1:-unknown} start_pos=${start_pos:-?} first_step=${first_step:-?} target=${SPLASHOS_TGT:-?} root=${splash_partition_root:-?}" >> "$log_dir/index.log" 2>/dev/null || true
	prune_build_logs
}

log_task_start() {
	# $1=task $2=free-text detail
	local log_dir
	log_dir=$(build_log_dir)
	mkdir -p "$log_dir" 2>/dev/null || true
	echo "[task] start $(date -Ins) task=$1 $2" >> "$log_dir/index.log" 2>/dev/null || true
	prune_build_logs
}

log_task_end() {
	# $1=task $2=status $3=free-text detail
	local log_dir
	log_dir=$(build_log_dir)
	mkdir -p "$log_dir" 2>/dev/null || true
	echo "[task] end   $(date -Ins) task=$1 status=$2 $3" >> "$log_dir/index.log" 2>/dev/null || true
}

prune_build_logs() {
	# Keep the newest 50 task logs; index.log is never pruned.
	local log_dir old
	log_dir=$(build_log_dir)
	while read -r old; do
		rm -f -- "$old"
	done < <(ls -1t "$log_dir"/*.log 2>/dev/null | grep -v '/index\.log$' | tail -n +51)
}

# On any nonzero exit: record the failing task in index.log and append a
# system snapshot (memory, pressure, disk) to the task's own log, so an OOM
# or ENOSPC kill can be ruled in/out from the log alone.
build_failure_trap() {
	local status=$?
	if [ "$status" != 0 ]; then
		if [ -n "${CURRENT_TASK:-}" ]; then
			log_task_end "$CURRENT_TASK" "$status" "index=${CURRENT_TASK_INDEX:-?} FAILED"
		fi
		if [ -n "${TASK_LOG_FILE:-}" ] && [ -f "$TASK_LOG_FILE" ]; then
			{
				echo "[splashbuilder] task FAILED with status $status; system snapshot:"
				free -m
				echo "-- memory pressure:"
				cat /proc/pressure/memory 2>/dev/null || true
				echo "-- disk:"
				df -m /
			} >> "$TASK_LOG_FILE" 2>&1 || true
		fi
	fi
}
trap 'build_failure_trap' EXIT


cleanup() {
	cd $(join_path $DIST_ROOT sources)
	rm -rf manifest.yml
	rm -rf build
	rm -rf patch
	
	if [ -n "$1" ]; then
		rm -rf $1
	fi

}


task_compile(){
	cd $(join_path $DIST_ROOT sources)

	# Remove leftovers from a previous (interrupted) attempt of this package so
	# extraction and configure always start from a clean tree
	if [ -d "${package}-${package_version}" ]; then
		rm -rf "${package}-${package_version}"
	fi

	tar --overwrite -xvf "${package}-${package_version}.tar.xz"

	echo "-------------------------------------------------------"
	echo "Processing ${package}(step: ${buildmode})"
	echo "-------------------------------------------------------"
	sleep 1

	
	cd "${package}-${package_version}"

	package_build=$(yq eval ".build.${buildmode}" "${DIST_ROOT}/sources/manifest.yml")
	package_build_script=$(echo "${package_build}" | yq eval ".script")
	package_build_patch=$(echo "${package_build}" | yq eval ".patch")

	# Snapshot the build config of this task, so an interrupted build can be
	# recovered and this task re-run (see 'recover' mode)
	rm -rf "$snapshot_dir"
	mkdir -p "$snapshot_dir"
	cp "${DIST_ROOT}/sources/manifest.yml" "$snapshot_dir/"
	cp -r "${DIST_ROOT}/sources/build" "$snapshot_dir/build"
	if [ -d "${DIST_ROOT}/sources/patch" ]; then
		cp -r "${DIST_ROOT}/sources/patch" "$snapshot_dir/patch"
	fi


	# Run patch + recipe in a subshell whose full output is teed to a per-task
	# log file. pipefail + set -e keep the abort-on-failure behavior identical
	# to a plain `source`; the EXIT trap (see top) records the failure in
	# index.log and appends a system snapshot to the task log.
	TASK_LOG_FILE="$(build_log_dir)/${package}-${package_version}-${buildmode}-$(date +%Y%m%d-%H%M%S).log"
	mkdir -p "$(build_log_dir)" 2>/dev/null || true
	echo "[splashbuilder] full task log: $TASK_LOG_FILE"

	(
		set -e
		trap 'echo "[splashbuilder] FAILED (status $?) at ${BASH_SOURCE[0]} line ${LINENO:-?}"' ERR
		if [ "${SPLASHBUILDER_DEBUG:-0}" = "1" ]; then
			set -x
		fi
		if [ "${package_build_patch}" != "false" ]; then
			patch -Np1 -i "../patch/${package_build_patch}"
		fi

		source "../build/${package_build_script}"
	) 2>&1 | tee "$TASK_LOG_FILE"

	cleanup "${package}-${package_version}"
}

task_chane_env(){
	cp -r $DIST_ROOT/config.yml $splash_partition_root
	cp -r $DIST_ROOT/edition-sources.yml $splash_partition_root
	cp -r $DIST_ROOT/SplashBuilder/core_build.sh $splash_partition_root
	
	# -T merges into an existing sources dir instead of nesting it, so the
	# chroot can be re-entered when recovering an interrupted build
	cp -rT $DIST_ROOT/sources $splash_partition_root/sources

	# Preparing Virtual Kernel File System
	mkdir -pv $splash_partition_root/{dev,proc,sys,run}

	# Check if directories are already mounted before attempting to mount
	if ! mountpoint -q $splash_partition_root/dev; then
		mount -v --bind /dev $splash_partition_root/dev
	fi

	if ! mountpoint -q $splash_partition_root/dev/pts; then
		mount -v --bind /dev/pts $splash_partition_root/dev/pts
	fi

	if ! mountpoint -q $splash_partition_root/proc; then
		mount -vt proc proc $splash_partition_root/proc
	fi

	if ! mountpoint -q $splash_partition_root/sys; then
		mount -vt sysfs sysfs $splash_partition_root/sys
	fi

	if ! mountpoint -q $splash_partition_root/run; then
		mount -vt tmpfs tmpfs $splash_partition_root/run
	fi
	
	if [ -h $splash_partition_root/dev/shm ]; then
		mkdir -pv $splash_partition_root/$(readlink $splash_partition_root/dev/shm)
	elif ! mountpoint -q $splash_partition_root/dev/shm; then
		mount -t tmpfs -o nosuid,nodev tmpfs $splash_partition_root/dev/shm
	fi
	
	
	
	
cat << EOF | sudo chroot "$splash_partition_root" /usr/bin/env -i HOME=/root TERM="$TERM" PS1='(splash chroot) \u:\w\$ ' PATH=/usr/bin:/usr/sbin LC_ALL=C SPLASHOS_TGT="$SPLASHOS_TGT" splash_partition_root=/ /bin/bash --login
	echo "Builder Current Step:"
	echo $i
	./core_build.sh env_chroot $i ${chroot_resume:-0}
EOF

	# Unmount in reverse order, guarded so an already-unmounted tree or a
	# busy mount does not abort the build (set -e)
	for vfs in dev/shm run sys proc dev/pts dev; do
		mountpoint -q "$splash_partition_root/$vfs" && umount "$splash_partition_root/$vfs"
	done
}



task_setup_chroot(){

	# Creating Directories
	mkdir -pv /{boot,home,mnt,opt,srv}

	mkdir -pv /etc/{opt,sysconfig}
	mkdir -pv /lib/firmware
	mkdir -pv /media/{floppy,cdrom}
	mkdir -pv /usr/{,local/}{include,src}
	mkdir -pv /usr/local/{bin,lib,sbin}
	mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
	mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
	mkdir -pv /usr/{,local/}share/man/man{1..8}
	mkdir -pv /var/{cache,local,log,mail,opt,spool}
	mkdir -pv /var/lib/{color,misc,locate}

	ln -sfv /run /var/run
	ln -sfv /run/lock /var/lock

	install -dv -m 0750 /root
	install -dv -m 1777 /tmp /var/tmp


	# Creating Essential Files and Symlinks
	ln -sfv /proc/self/mounts /etc/mtab

cat > /etc/hosts << EOF
127.0.0.1  localhost $(hostname)
::1        localhost
EOF

cat > /etc/passwd << EOF
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
systemd-journal-gateway:x:73:73:systemd Journal Gateway:/:/usr/bin/false
systemd-journal-remote:x:74:74:systemd Journal Remote:/:/usr/bin/false
systemd-journal-upload:x:75:75:systemd Journal Upload:/:/usr/bin/false
systemd-network:x:76:76:systemd Network Management:/:/usr/bin/false
systemd-resolve:x:77:77:systemd Resolver:/:/usr/bin/false
systemd-timesync:x:78:78:systemd Time Synchronization:/:/usr/bin/false
systemd-coredump:x:79:79:systemd Core Dumper:/:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
systemd-oom:x:81:81:systemd Out Of Memory Daemon:/:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF

cat > /etc/group << EOF
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
systemd-journal:x:23:
input:x:24:
mail:x:34:
kvm:x:61:
systemd-journal-gateway:x:73:
systemd-journal-remote:x:74:
systemd-journal-upload:x:75:
systemd-network:x:76:
systemd-resolve:x:77:
systemd-timesync:x:78:
systemd-coredump:x:79:
uuidd:x:80:
systemd-oom:x:81:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF

	touch /var/log/{btmp,lastlog,faillog,wtmp}
	chgrp -v utmp /var/log/lastlog
	chmod -v 664  /var/log/lastlog
	chmod -v 600  /var/log/btmp

	#reset enviroment
	find /sources -maxdepth 1 -mindepth 1 -type d -exec rm -rf '{}' \;

}

[ "$1" != "env_chroot" ] && start_pos=0 || start_pos=$2

# --- Recovery / checkpointing -------------------------------------------------
# Progress is checkpointed on the build partition after every successful task:
#   .build_state     - index of the next task to run (shell-sourceable)
#   .build_snapshot/ - build config (manifest.yml, build/, patch/) of the task
#                      that was running, restored when the build is recovered
# 'core_build.sh recover' (offered by run.sh) continues from the last
# checkpoint instead of wiping the partition and starting over.
if [ "$1" = "env_chroot" ]; then
	# Inside the chroot the build partition root is "/"; the host reads and
	# writes .build_state/.build_snapshot there, so the dot-names must match
	# (without them the chroot checkpoints landed in build_state, which the
	# host's recover logic never looks at).
	state_file="/.build_state"
	snapshot_dir="/.build_snapshot"
else
	state_file="$splash_partition_root/.build_state"
	snapshot_dir="$splash_partition_root/.build_snapshot"
fi

# Final cleanup stage: remove everything the build put on the target
# partition that is not part of the finished system (LFS does the same when
# the build is complete: delete the temp toolchain and the build leftovers).
#
# Host-side only; runs once after the last task succeeded:
#   core_build.sh, config.yml, edition-sources.yml, sources/
#       -> copied in by task_chane_env for the chroot phase
#   tools/
#       -> the cross toolchain (LFS temp tools)
#   .build_snapshot/
#       -> build config snapshots; BUILD_STEP == build_count at this point,
#          so the restore logic can never fire again
# .build_state and .build_logs are deliberately kept: the state file makes a
# rerun print "Build already complete" instead of wiping the partition, and
# the logs stay available for diagnostics.
task_cleanup() {
	echo "Cleanup: removing build leftovers from $splash_partition_root"
	local before after
	before=$(df -m "$splash_partition_root" | awk 'NR==2 {print $3}')
	rm -rf "$splash_partition_root/core_build.sh" \
	       "$splash_partition_root/config.yml" \
	       "$splash_partition_root/edition-sources.yml" \
	       "$splash_partition_root/sources" \
	       "$splash_partition_root/tools" \
	       "$splash_partition_root/.build_snapshot"
	after=$(df -m "$splash_partition_root" | awk 'NR==2 {print $3}')
	log_task_end "cleanup" 0 "index=end freed=$((before - after)) MiB"
	echo "Cleanup: freed $((before - after)) MiB."
}

case "$1" in
	env_chroot) edition_file="/edition-sources.yml" ;;
	*)          edition_file="${DIST_ROOT}/edition-sources.yml" ;;
esac

save_checkpoint() {
	# $1 = next top-level task index, $2 = next chroot task index
	edition_hash=$(md5sum "$edition_file" 2>/dev/null | cut -d' ' -f1)
	cat > "$state_file" <<EOF
BUILD_STEP=$1
CHROOT_STEP=${2:-0}
SPLASHOS_TGT=$SPLASHOS_TGT
EDITION_HASH=$edition_hash
EOF
}

# edition_prefix_unchanged OLD NEW BUILD_STEP CHROOT_STEP
# Succeeds when OLD and NEW define the same top-level tasks before
# BUILD_STEP and, within task BUILD_STEP, the same chroot tasks before
# CHROOT_STEP. OLD must be the config the checkpoint was written with.
edition_prefix_unchanged() {
	local old=$1 new=$2 step=$3 chroot_step=$4 i
	[ -f "$old" ] && [ -f "$new" ] || return 1
	[ "$(md5sum "$old" | cut -d' ' -f1)" = "$EDITION_HASH" ] || return 1
	for ((i = 0; i < step; i++)); do
		[ "$(yq -o=json eval ".build[$i]" "$old")" = "$(yq -o=json eval ".build[$i]" "$new")" ] || return 1
	done
	# The resumed task itself must still be the same kind of task, and its
	# completed chroot steps must match one by one.
	[ "$(yq -o=json eval ".build[$step] | del(.build)" "$old")" = \
	  "$(yq -o=json eval ".build[$step] | del(.build)" "$new")" ] || return 1
	for ((i = 0; i < chroot_step; i++)); do
		[ "$(yq -o=json eval ".build[$step].build[$i]" "$old")" = \
		  "$(yq -o=json eval ".build[$step].build[$i]" "$new")" ] || return 1
	done
	return 0
}

first_step=0
chroot_resume=0

if [ "$1" = "env_chroot" ]; then
	# $3 = optional position inside the chroot task list to resume from
	first_step=${3:-0}
elif [ "$1" = "recover" ]; then
	if [ ! -f "$state_file" ]; then
		echo "No build snapshot found at $state_file, nothing to recover."
		echo "Start a fresh build instead."
		exit 1
	fi

	expected_tgt="$SPLASHOS_TGT"
	source "$state_file"

	if [ -n "$expected_tgt" ] && [ "$SPLASHOS_TGT" != "$expected_tgt" ]; then
		echo "Snapshot was taken for SPLASHOS_TGT=$SPLASHOS_TGT but the current target is $expected_tgt."
		echo "Remove $state_file to start a fresh build."
		exit 1
	fi

	current_hash=$(md5sum "$edition_file" 2>/dev/null | cut -d' ' -f1)
	if [ -n "$EDITION_HASH" ] && [ -n "$current_hash" ] && [ "$EDITION_HASH" != "$current_hash" ]; then
		# The edition config changed (e.g. a package was added to fix a
		# failed build). Resuming is still safe when everything that already
		# ran is unchanged: the top-level tasks before BUILD_STEP and, inside
		# the task being resumed, the chroot tasks before CHROOT_STEP. The
		# copy on the partition is the config the snapshot was taken with
		# (task_chane_env copies it in; verified via EDITION_HASH).
		old_edition="$splash_partition_root/edition-sources.yml"
		if ! edition_prefix_unchanged "$old_edition" "$edition_file" "${BUILD_STEP:-0}" "${CHROOT_STEP:-0}"; then
			echo "edition-sources.yml changed since the snapshot was taken, including"
			echo "tasks that already ran. Remove $state_file to start a fresh build."
			exit 1
		fi
		echo "edition-sources.yml changed after the resume point; the completed tasks are unchanged, resuming."
	fi

	first_step=${BUILD_STEP:-0}
	chroot_resume=${CHROOT_STEP:-0}
	echo "Recovering build from task $first_step (chroot step: $chroot_resume)"
else
	# Fresh build: discard any previous snapshot
	rm -rf "$snapshot_dir"
	save_checkpoint 0 0
fi

# Get build data from build configuration file
if [ "$1" != "env_chroot" ]; then
	build_data=$(yq eval ".build" "${DIST_ROOT}/edition-sources.yml")
else
	build_data=$(yq eval ".build[${start_pos}].build" "/edition-sources.yml")
fi

build_count=$(echo "${build_data}" | yq eval ". | length")

log_run_start "${1:-fresh}"

if [ "$first_step" -ge "$build_count" ]; then
	# The build finished. Make sure the final cleanup ran even when the last
	# checkpoint was written by an older builder version without the cleanup
	# stage (idempotent: removes nothing on an already-clean partition).
	if [ "$1" != "env_chroot" ]; then
		CURRENT_TASK="cleanup"
		CURRENT_TASK_INDEX="end"
		TASK_LOG_FILE=""
		log_task_start "cleanup" "index=end"
		task_cleanup
	fi
	echo "Build already complete, nothing to do."
	exit 0
fi
	
# Run Build
for (( i=${first_step}; i<build_count; ++i)); do
	echo "running loop";
	
	# Cleanup the temporarily files
	cleanup "${package}-${package_version}"

	# Get spesific task
	task=$(echo "${build_data}" | yq eval ".[$i].task")

	echo "TASK: $task"

	# Task context for the logging helpers / EXIT trap (see top of file)
	CURRENT_TASK="$task"
	CURRENT_TASK_INDEX="$i"
	TASK_LOG_FILE=""
	log_task_start "$task" "index=$i"

	# If the build config for this task is missing (it is removed by cleanup
	# after every pass), restore it from the snapshot taken when it last ran.
	# Only restore when the snapshot belongs to the same package, so a
	# mid-run injected config is never overwritten with a stale one.
	if [ "$task" = "compile" ] && [ -f "$snapshot_dir/manifest.yml" ] \
	   && [ ! -f "${DIST_ROOT}/sources/manifest.yml" ]; then
		task_package=$(echo "${build_data}" | yq eval ".[$i].package" | tr '[:upper:]' '[:lower:]')
		snapshot_package=$(yq eval '.package' "$snapshot_dir/manifest.yml" | tr '[:upper:]' '[:lower:]')
		if [ "$task_package" = "$snapshot_package" ]; then
			echo "Restoring build config for ${task_package} from snapshot..."
			cp -rT "$snapshot_dir" "${DIST_ROOT}/sources"
		fi
	fi

	if [ "$task" = "change_enviroment" ]; then
		enviroment=$(echo "${build_data}" | yq eval ".[$i].enviroment")
		echo "At the change enviroment step."

		if [ "$enviroment" = "chroot" ]; then
			task_chane_env
			# The recovery resume index (CHROOT_STEP) applies only to the
			# chroot section the build stopped in. Once that section has
			# run, any LATER chroot section must start from its own
			# beginning — otherwise its task list is compared against a
			# stale index and gets skipped entirely.
			chroot_resume=0
		else
			echo "Unknown enviroment type '${enviroment}', exiting.."
			exit
		fi
	elif [ "$task" = "setup_chroot" ]; then
		task_setup_chroot
		
	elif [ "$task" = "custom" ]; then
		commands=$(echo "${build_data}" | yq eval ".[$i].commands")
		commands_count=$(echo "${commands}" | yq eval ". | length")
		
		for (( i2=0; i2<commands_count; ++i2)); do
			command=$(echo "${commands}" | yq eval ".[$i2]")
			# Must be quoted: an unquoted expansion re-joins the command with
			# spaces, which destroys newlines and breaks multi-line commands
			# (e.g. heredocs) even when the edition YAML is correct.
			eval "${command}"
		done
		
	elif [ "$task" = "compile" ]; then
	
		package=$(echo "${build_data}" | yq eval ".[$i].package")
		buildmode=$(echo "${build_data}" | yq eval ".[$i].buildmode")
		package_version=$(yq eval '.packages[] | select(.package == "'"$package"'") | .version' "${DIST_ROOT}/edition-sources.yml")
	
		task_compile $package $package_version $buildmode
	else
		echo "Unknown task type '${task}', exiting.."
		exit
	
	fi

	# Reached only on success (a failing task aborts via set -e and the EXIT
	# trap records it). Package details for compile tasks come from this
	# iteration's globals.
	if [ "$task" = "compile" ]; then
		log_task_end "$task" 0 "index=$i package=$package version=$package_version mode=$buildmode log=$TASK_LOG_FILE"
	else
		log_task_end "$task" 0 "index=$i"
	fi

	# Checkpoint after every successful pass so the build can be resumed here
	if [ "$1" = "env_chroot" ]; then
		save_checkpoint "$start_pos" "$((i+1))"
	else
		save_checkpoint "$((i+1))" 0
	fi

done

# --- Final cleanup stage (host side only) ------------------------------------
# Only reached when every task succeeded; a failure aborts earlier via set -e
# and leaves the state file intact for recovery.
if [ "$1" != "env_chroot" ]; then
	CURRENT_TASK="cleanup"
	CURRENT_TASK_INDEX="end"
	TASK_LOG_FILE=""
	log_task_start "cleanup" "index=end"
	task_cleanup
fi
	
	



