. $DIST_ROOT/build_env/build_scripts/inc-start.sh $1 $(basename $0)

sed '6009s/$add_dir//' -i ltmain.sh

mkdir -pv build
cd       build

../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --disable-werror           \
    --enable-64-bit-bfd

make
make DESTDIR=$LFS install


. $DIST_ROOT/build_env/build_scripts/inc-end.sh $1 $(basename $0)
