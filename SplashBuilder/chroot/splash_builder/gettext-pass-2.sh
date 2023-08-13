. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.21.1

make
make check
make install

chmod -v 0755 /usr/lib/preloadable_libintl.so

. /splash_builder/inc-end.sh $1 $(basename $0)
