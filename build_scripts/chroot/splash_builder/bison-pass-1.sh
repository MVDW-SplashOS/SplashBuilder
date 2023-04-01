. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2

make
make install

. /splash_builder/inc-end.sh $1 $(basename $0)
