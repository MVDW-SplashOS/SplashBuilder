. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.2 \
            --disable-static                        \
            --disable-kill                          \
            --with-systemd

make
make install

. /splash_builder/inc-end.sh $1 $(basename $0)
