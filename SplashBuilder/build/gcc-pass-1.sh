echo ${splash_partition_root:?}
echo ${SPLASHOS_TGT:?}


. $DIST_ROOT/build_scripts/build/inc-start.sh $1 $(basename $0)


tar -xf "../mpfr-${config_tools_list__mpfr__version}.tar.xz"
mv -vn "mpfr-${config_tools_list__mpfr__version}" mpfr
tar -xf "../gmp-${config_tools_list__gmp__version}.tar.xz"
mv -vn "gmp-${config_tools_list__gmp__version}" gmp
tar -xf "../mpc-${config_tools_list__mpc__version}.tar.xz"
mv -vn "mpc-${config_tools_list__mpc__version}" mpc


sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
        

mkdir -pv build
cd       build
    
    
../configure                  \
    --target=$SPLASHOS_TGT         \
    --prefix=$splash_partition_root/tools       \
    --with-glibc-version=2.37 \
    --with-sysroot=$splash_partition_root       \
    --with-newlib             \
    --without-headers         \
    --enable-default-pie      \
    --enable-default-ssp      \
    --disable-nls             \
    --disable-shared          \
    --disable-multilib        \
    --disable-threads         \
    --disable-libatomic       \
    --disable-libgomp         \
    --disable-libquadmath     \
    --disable-libssp          \
    --disable-libvtv          \
    --disable-libstdcxx       \
    --enable-languages=c,c++
    
make
make install

cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($SPLASHOS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
pwd

. $DIST_ROOT/build_scripts/build/inc-end.sh $1 $(basename $0)
