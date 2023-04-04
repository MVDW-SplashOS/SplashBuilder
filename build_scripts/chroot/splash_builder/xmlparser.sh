. /splash_builder/inc-start.sh $1 $(basename $0)

perl Makefile.PL

make
make install

. /splash_builder/inc-end.sh $1 $(basename $0)
