. /splash_builder/inc-start.sh $1 $(basename $0)

make prefix=/usr install

. /splash_builder/inc-end.sh $1 $(basename $0)
