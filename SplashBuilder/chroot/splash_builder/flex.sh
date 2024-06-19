. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static
            
make
make check
make install

ln -sfv flex /usr/bin/lex

. /splash_builder/inc-end.sh $1 $(basename $0)
