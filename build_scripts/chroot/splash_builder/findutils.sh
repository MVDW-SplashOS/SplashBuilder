. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr --localstatedir=/var/lib/locate

make
make install


. /splash_builder/inc-end.sh $1 $(basename $0)
