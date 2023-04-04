. /splash_builder/inc-start.sh $1 $(basename $0)

unset {C,CPP,CXX,LD}FLAGS

patch -Np1 -i ../grub-2.06-upstream_fixes-1.patch

./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror
            
make
make install

mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions

. /splash_builder/inc-end.sh $1 $(basename $0)
