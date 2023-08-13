. /splash_builder/inc-start.sh $1 $(basename $0)

echo $MAKEFLAGS

#expect -c "spawn ls"
#spawn ls #TODO: Check if output was "The system has no more ptys. Ask your system administrator to create more." if so, stop building.

mkdir -pv build
cd       build

../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib

make tooldir=/usr
#make -k check
#grep '^FAIL:' $(find -name '*.log')
make tooldir=/usr install

rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,sframe,opcodes}.a
rm -fv /usr/share/man/man1/{gprofng,gp-*}.1

. /splash_builder/inc-end.sh $1 $(basename $0)
