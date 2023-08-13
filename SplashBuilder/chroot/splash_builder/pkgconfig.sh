. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr              \
            --with-internal-glib       \
            --disable-host-tool        \
            --docdir=/usr/share/doc/pkg-config-0.29.2
            

make
#make check
make install

. /splash_builder/inc-end.sh $1 $(basename $0)
