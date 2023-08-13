. $DIST_ROOT/build_scripts/build/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr                     \
            --host=$SPLASHOS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.4.1

make
make DESTDIR=$splash_partition_root install

rm -v $splash_partition_root/usr/lib/liblzma.la

. $DIST_ROOT/build_scripts/build/inc-end.sh $1 $(basename $0)
