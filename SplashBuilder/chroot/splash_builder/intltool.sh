. /splash_builder/inc-start.sh $1 $(basename $0)

sed -i 's:\\\${:\\\$\\{:' intltool-update.in

./configure --prefix=/usr

make
make install

install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

. /splash_builder/inc-end.sh $1 $(basename $0)
