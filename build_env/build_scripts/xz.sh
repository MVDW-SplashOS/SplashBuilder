. $DIST_ROOT/build_env/build_scripts/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.2.5
make

make DESTDIR=$LFS install


. $DIST_ROOT/build_env/build_scripts/inc-end.sh $1 $(basename $0)
