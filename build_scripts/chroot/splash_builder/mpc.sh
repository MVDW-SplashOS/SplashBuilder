. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.3.1
         


make
make html
make check

make install
make install-html

. /splash_builder/inc-end.sh $1 $(basename $0)
