. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.5.0

make
make install

install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.5.0

. /splash_builder/inc-end.sh $1 $(basename $0)
