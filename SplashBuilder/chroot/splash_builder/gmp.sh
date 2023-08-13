. /splash_builder/inc-start.sh $1 $(basename $0)

#Make genric binaries
cp -v configfsf.guess config.guess
cp -v configfsf.sub   config.sub

./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.2.1
            
make
make html

make check 2>&1 | tee gmp-check-log

awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log #TODO: Check if all 197 tests passed, if not stop build.

make install
make install-html

. /splash_builder/inc-end.sh $1 $(basename $0)
