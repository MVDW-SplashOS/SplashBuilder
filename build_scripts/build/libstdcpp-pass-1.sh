. ./build_scripts/build/inc-start.sh $1 $(basename $0)

echo ${splash_partition_root:?}
echo ${SPLASHOS_TGT:?}

mkdir -pv build
cd       build

../libstdc++-v3/configure           \
    --host=$SPLASHOS_TGT                 \
    --build=$(../config.guess)      \
    --prefix=/usr                   \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$SPLASHOS_TGT/include/c++/12.2.0
    
    
make
make DESTDIR=$splash_partition_root install

rm -v $splash_partition_root/usr/lib/lib{stdc++,stdc++fs,supc++}.la

#. $DIST_ROOT/build_env/build_scripts/inc-end.sh $1 $(basename $0)

