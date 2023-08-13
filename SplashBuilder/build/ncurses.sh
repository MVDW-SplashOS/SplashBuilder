. $DIST_ROOT/build_scripts/build/inc-start.sh $1 $(basename $0)

sed -i s/mawk// configure

mkdir -p build
pushd build
  ../configure
  make -C include
  make -C progs tic
popd

./configure --prefix=/usr                \
            --host=$SPLASHOS_TGT         \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping          \
            --enable-widec
            

make
make DESTDIR=$splash_partition_root TIC_PATH=$(pwd)/build/progs/tic install
echo "INPUT(-lncursesw)" > $splash_partition_root/usr/lib/libncurses.so


. $DIST_ROOT/build_scripts/build/inc-end.sh $1 $(basename $0)
