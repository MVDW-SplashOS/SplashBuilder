. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr   \
            --enable-shared \
            --without-ensurepip

make
make install

. /splash_builder/inc-end.sh $1 $(basename $0)
