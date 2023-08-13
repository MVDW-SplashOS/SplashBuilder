. $DIST_ROOT/build_scripts/build/inc-start.sh $1 $(basename $0)

mkdir build
pushd build
  ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
  make
popd

./configure --prefix=/usr --host=$SPLASHOS_TGT --build=$(./config.guess)

make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$splash_partition_root install

rm -vf $splash_partition_root/usr/lib/libmagic.la

. $DIST_ROOT/build_scripts/build/inc-end.sh $1 $(basename $0)
