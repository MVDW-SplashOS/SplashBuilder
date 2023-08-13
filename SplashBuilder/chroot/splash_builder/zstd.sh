. /splash_builder/inc-start.sh $1 $(basename $0)

make prefix=/usr
make check
make prefix=/usr install

rm -fv /usr/lib/libzstd.a

. /splash_builder/inc-end.sh $1 $(basename $0)
