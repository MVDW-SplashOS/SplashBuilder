. /splash_builder/inc-start.sh $1 $(basename $0)

PAGE=A4 ./configure --prefix=/usr

make
make install


. /splash_builder/inc-end.sh $1 $(basename $0)