. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --disable-shared

make
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

. /splash_builder/inc-end.sh $1 $(basename $0)
