. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include

make
make test
make install
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib

. /splash_builder/inc-end.sh $1 $(basename $0)
