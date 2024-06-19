. /splash_builder/inc-start.sh $1 $(basename $0)

./configure --prefix=/usr

make
make install
make TEXMF=/usr/share/texmf install-tex

pushd /usr/share/info
  rm -v dir
  for f in *
    do install-info $f dir 2>/dev/null
  done
popd


. /splash_builder/inc-end.sh $1 $(basename $0)
