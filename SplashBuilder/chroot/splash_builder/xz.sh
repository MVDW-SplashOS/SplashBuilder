. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.4.1
            
make
make check
make install

. /splash_builder/inc-end.sh $1 $(basename $0)
