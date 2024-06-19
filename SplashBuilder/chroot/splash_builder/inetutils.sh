. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers

make
make install

mv -v /usr/{,s}bin/ifconfig

. /splash_builder/inc-end.sh $1 $(basename $0)
