. /splash_builder/inc-start.sh $1 $(basename $0)

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure --prefix=/usr

make
make install


ln -sfv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sfv vim.1 $(dirname $L)/vi.1
done

ln -sfv ../vim/vim90/doc /usr/share/doc/vim-9.0.1273

. /splash_builder/inc-end.sh $1 $(basename $0)
