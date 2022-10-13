LOCAL_USERNAME=$1
if [[ $# -eq 0 ]]; then
	LOCAL_USERNAME=$USER
fi


LOCAL_DIST_ROOT=$(pwd)
echo $LOCAL_DIST_ROOT

if test -d $LOCAL_DIST_ROOT; then
	export DIST_ROOT="$LOCAL_DIST_ROOT"
	export LFS="$DIST_ROOT/build_env/build_root"
	echo "The enviroment DIST_ROOT and LFS has been set for user $LOCAL_USERNAME."
	echo ""
	echo "DIST_ROOT: $LOCAL_DIST_ROOT" 
	echo "LFS: $LOCAL_DIST_ROOT/build_env/build_root" 
else
	echo "Failed to set enviroment, check if the following folders exists:"
	echo ""
	echo "DIST_ROOT: $LOCAL_DIST_ROOT" 
	echo "LFS: $LOCAL_DIST_ROOT/build_env/build_root" 
fi
