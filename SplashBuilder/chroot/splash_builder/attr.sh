. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.1

make
make check
make install

. /splash_builder/inc-end.sh $1 $(basename $0)
