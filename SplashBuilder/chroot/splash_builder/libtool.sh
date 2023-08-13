. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr

make
make install

rm -fv /usr/lib/libltdl.a

. /splash_builder/inc-end.sh $1 $(basename $0)
