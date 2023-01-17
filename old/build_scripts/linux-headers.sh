set -e

. $DIST_ROOT/build_env/build_scripts/inc-start.sh $1 $(basename $0)

make mrproper

make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr

. $DIST_ROOT/build_env/build_scripts/inc-start.sh $1 $(basename $0)

