. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native

make
make install


. /splash_builder/inc-end.sh $1 $(basename $0)
