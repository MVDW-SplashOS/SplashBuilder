. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native

make
make check
make install


# Dirty "Fix" for building error
ln -f /usr/lib64/libffi.la /usr/lib/libffi.la
ln -f /usr/lib64/libffi.so.8.1.2 /usr/lib/libffi.so.8.1.2
ln -f /usr/lib64/libffi.so.8.1.2 /usr/lib/libffi.so.8 
ln -f /usr/lib64/libffi.so.8.1.2 /usr/lib/libffi.so


. /splash_builder/inc-end.sh $1 $(basename $0)
