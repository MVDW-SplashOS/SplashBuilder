. /splash_builder/inc-start.sh $1 $(basename $0)

sed -e '/ifdef SIGPIPE/,+2 d' \
    -e '/undef  FATAL_SIG/i FATAL_SIG (SIGPIPE);' \
    -i src/main.c

./configure --prefix=/usr

make
make install

. /splash_builder/inc-end.sh $1 $(basename $0)
