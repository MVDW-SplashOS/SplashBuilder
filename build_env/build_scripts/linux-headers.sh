. $DIST_ROOT/build_env/build_scripts/inc-start.sh $1 $(basename $0)

make mrproper

make headers
find usr/include -name '.*' -delete
rm usr/include/Makefile
cp -rv usr/include $LFS/usr

. $DIST_ROOT/build_env/build_scripts/inc-start.sh $1 $(basename $0)

