. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy

make
make -C libelf install

install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a


. /splash_builder/inc-end.sh $1 $(basename $0)
