. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr --disable-static
make

make docdir=/usr/share/doc/check-0.15.2 install

. /splash_builder/inc-end.sh $1 $(basename $0)
