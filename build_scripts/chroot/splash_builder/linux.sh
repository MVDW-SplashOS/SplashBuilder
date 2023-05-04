. /splash_builder/inc-start.sh $1 $(basename $0)

make mrproper
make defconfig

cp /sources/.config .

make
make modules_install

cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.1.11-splashos-v0.1dev
cp -iv System.map /boot/System.map-6.1.11
cp -iv .config /boot/config-6.1.11

install -d /usr/share/doc/linux-6.1.11
cp -r Documentation/* /usr/share/doc/linux-6.1.11

. /splash_builder/inc-end.sh $1 $(basename $0)
