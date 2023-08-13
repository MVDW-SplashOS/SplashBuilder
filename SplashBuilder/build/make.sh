. $DIST_ROOT/build_scripts/build/inc-start.sh $1 $(basename $0)

sed -e '/ifdef SIGPIPE/,+2 d' \
    -e '/undef  FATAL_SIG/i FATAL_SIG (SIGPIPE);' \
    -i src/main.c

./configure --prefix=/usr   \
            --without-guile \
            --host=$SPLASHOS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$splash_partition_root install

. $DIST_ROOT/build_scripts/build/inc-end.sh $1 $(basename $0)
