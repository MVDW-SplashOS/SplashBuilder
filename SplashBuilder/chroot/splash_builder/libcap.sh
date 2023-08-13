. /splash_builder/inc-start.sh $1 $(basename $0)

sed -i '/install -m.*STA/d' libcap/Makefile

make prefix=/usr lib=lib
make test
make prefix=/usr lib=lib install


. /splash_builder/inc-end.sh $1 $(basename $0)
