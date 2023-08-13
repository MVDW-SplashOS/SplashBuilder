. /splash_builder/inc-start.sh $1 $(basename $0)

meson .
meson compile
meson test

. /splash_builder/inc-end.sh $1 $(basename $0)
