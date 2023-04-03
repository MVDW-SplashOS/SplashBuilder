. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr         \
            --disable-static      \
            --docdir=/usr/share/doc/acl-2.3.1
            

make
make install


. /splash_builder/inc-end.sh $1 $(basename $0)
