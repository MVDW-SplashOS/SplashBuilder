. $DIST_ROOT/build_env/build_scripts/inc-start.sh $1 $(basename $0)

# Include and parse yaml script
source $DIST_ROOT/build_env/build_scripts/includes/parse_yaml.sh
create_variables $DIST_ROOT/build_env/config.yml "config_"

tar -xf "../mpfr-${config_tools_list__mpfr__version}.tar.xz"
mv -v "mpfr-${config_tools_list__mpfr__version}" mpfr
tar -xf "../gmp-${config_tools_list__gmp__version}.tar.xz"
mv -v "gmp-${config_tools_list__gmp__version}" gmp
tar -xf "../mpc-${config_tools_list__mpc__version}.tar.gz"
mv -v "mpc-${config_tools_list__mpc__version}" mpc

sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64

mkdir -pv build
cd       build

../configure                  \
    --target=$LFS_TGT         \
    --prefix=$LFS/tools       \
    --with-glibc-version=2.35 \
    --with-sysroot=$LFS       \
    --with-newlib             \
    --without-headers         \
    --enable-initfini-array   \
    --disable-nls             \
    --disable-shared          \
    --disable-multilib        \
    --disable-decimal-float   \
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
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h


. $DIST_ROOT/build_env/build_scripts/inc-end.sh $1 $(basename $0)
