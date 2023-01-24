. ./inc-start.sh $1 $(basename $0)

mkdir -pv build
cd       build

../configure --prefix=$splash_partition_root/tools       \
             --with-sysroot=$splash_partition_root        \
             --target=$SPLASHOS_TGT          \
             --disable-nls              \
             --disable-werror

make && make install


#. $DIST_ROOT/build_env/build_scripts/inc-end.sh $1 $(basename $0)