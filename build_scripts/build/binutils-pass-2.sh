. $DIST_ROOT/build_scripts/build/inc-start.sh $1 $(basename $0)

echo ${splash_partition_root:?}
echo ${SPLASHOS_TGT:?}


sed '6009s/$add_dir//' -i ltmain.sh

mkdir -pv build
cd       build

../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$SPLASHOS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --enable-gprofng=no        \
    --disable-werror           \
    --enable-64-bit-bfd
    
    
make
make install

rm -v $splash_partition_root/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.{a,la}

. $DIST_ROOT/build_scripts/build/inc-end.sh $1 $(basename $0)
