. $DIST_ROOT/build_scripts/build/inc-start.sh $1 $(basename $0)
echo ${splash_partition_root:?}
echo ${SPLASHOS_TGT:?}

ln -sfv ../lib/ld-linux-x86-64.so.2 $splash_partition_root/lib64
ln -sfv ../lib/ld-linux-x86-64.so.2 $splash_partition_root/lib64/ld-lsb-x86-64.so.3

patch -Np1 -i ../glibc-2.37-fhs-1.patch

mkdir -pv build
cd       build

echo "rootsbindir=/usr/sbin" > configparms

../configure                             \
      --prefix=/usr                      \
      --host=$SPLASHOS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=$splash_partition_root/usr/include    \
      libc_cv_slibdir=/usr/lib

make

make DESTDIR=$splash_partition_root install

sed '/RTLDLIST=/s@/usr@@g' -i $splash_partition_root/usr/bin/ldd


$splash_partition_root/tools/libexec/gcc/$SPLASHOS_TGT/12.2.0/install-tools/mkheaders


. $DIST_ROOT/build_scripts/build/inc-end.sh $1 $(basename $0)
