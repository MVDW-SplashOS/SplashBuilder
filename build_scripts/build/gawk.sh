. $DIST_ROOT/build_scripts/build/inc-start.sh $1 $(basename $0)

sed -i 's/extras//' Makefile.in


./configure --prefix=/usr   \
            --host=$SPLASHOS_TGT \
            --build=$(build-aux/config.guess)
make
make DESTDIR=$splash_partition_root install

. $DIST_ROOT/build_scripts/build/inc-end.sh $1 $(basename $0)
