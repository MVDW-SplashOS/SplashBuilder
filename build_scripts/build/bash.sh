. $DIST_ROOT/build_scripts/build/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$SPLASHOS_TGT                    \
            --without-bash-malloc

make
make DESTDIR=$splash_partition_root install
ln -sv bash $splash_partition_root/bin/sh

. $DIST_ROOT/build_scripts/build/inc-end.sh $1 $(basename $0)
