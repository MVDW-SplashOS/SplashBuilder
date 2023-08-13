. /splash_builder/inc-start.sh $1 $(basename $0)

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr

make
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.34


. /splash_builder/inc-end.sh $1 $(basename $0)
