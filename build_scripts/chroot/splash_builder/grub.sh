. /splash_builder/inc-start.sh $1 $(basename $0)

unset {C,CPP,CXX,LD}FLAGS


./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror
            
make
make install

mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions

. /splash_builder/inc-end.sh $1 $(basename $0)
