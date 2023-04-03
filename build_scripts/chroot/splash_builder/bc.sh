. /splash_builder/inc-start.sh $1 $(basename $0)

CC=gcc ./configure --prefix=/usr -G -O3 -r

make
make test
make install

. /splash_builder/inc-end.sh $1 $(basename $0)
