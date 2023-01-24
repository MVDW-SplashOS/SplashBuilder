# Include and parse yaml script
echo ${splash_partition_root:?}
echo ${SPLASHOS_TGT:?}

export yaml_file=./config.yml
export yaml_prefix="config_"
source ./build_scripts/parse_yaml.sh
create_variables 

. ./build_scripts/build/inc-start.sh $1 $(basename $0)

#
#tar -xf "../mpfr-${config_tools_list__mpfr__version}.tar.xz"
#mv -vn "mpfr-${config_tools_list__mpfr__version}" mpfr
#tar -xf "../gmp-${config_tools_list__gmp__version}.tar.xz"
#mv -vn "gmp-${config_tools_list__gmp__version}" gmp
#tar -xf "../mpc-${config_tools_list__mpc__version}.tar.gz"
#mv -vn "mpc-${config_tools_list__mpc__version}" mpc

tar -xf ../mpfr-4.1.0.tar.xz
mv -vn mpfr-4.1.0 mpfr
tar -xf ../gmp-6.2.1.tar.xz
mv -vn gmp-6.2.1 gmp
tar -xf ../mpc-1.2.1.tar.gz
mv -vn mpc-1.2.1 mpc


sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
        

mkdir -pv build
cd       build
    
    
../configure                  \
    --target=$SPLASHOS_TGT         \
    --prefix=$splash_partition_root/tools       \
    --with-glibc-version=2.36 \
    --with-sysroot=$splash_partition_root       \
    --with-newlib             \
    --without-headers         \
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
  `dirname $($SPLASHOS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
pwd

#. $DIST_ROOT/build_env/build_scripts/inc-end.sh $1 $(basename $0)
