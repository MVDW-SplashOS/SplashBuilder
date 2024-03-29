# Include and parse yaml script
echo ${splash_partition_root:?}
echo ${SPLASHOS_TGT:?}


. $DIST_ROOT/build_scripts/build/inc-start.sh $1 $(basename $0)


tar -xf "../mpfr-${config_tools_list__mpfr__version}.tar.xz"
mv -vn "mpfr-${config_tools_list__mpfr__version}" mpfr
tar -xf "../gmp-${config_tools_list__gmp__version}.tar.xz"
mv -vn "gmp-${config_tools_list__gmp__version}" gmp
tar -xf "../mpc-${config_tools_list__mpc__version}.tar.gz"
mv -vn "mpc-${config_tools_list__mpc__version}" mpc



sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in       

mkdir -pv build
cd       build
    
    
../configure                                       \
    --build=$(../config.guess)                     \
    --host=$SPLASHOS_TGT                                \
    --target=$SPLASHOS_TGT                              \
    LDFLAGS_FOR_TARGET=-L$PWD/$SPLASHOS_TGT/libgcc      \
    --prefix=/usr                                  \
    --with-build-sysroot=$splash_partition_root                      \
    --enable-default-pie                           \
    --enable-default-ssp                           \
    --disable-nls                                  \
    --disable-multilib                             \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --enable-languages=c,c++
    
make
make DESTDIR=$splash_partition_root install

ln -sv gcc $splash_partition_root/usr/bin/cc

. $DIST_ROOT/build_scripts/build/inc-end.sh $1 $(basename $0)
