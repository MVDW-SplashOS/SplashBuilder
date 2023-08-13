. /splash_builder/inc-start.sh $1 $(basename $0)

patch neofetch < ../neofetch.patch

make install


. /splash_builder/inc-end.sh $1 $(basename $0)
