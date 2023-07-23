set -e

echo "SplashOS Chroot Setup"



echo ""

export yaml_file=/config.yml
export yaml_prefix="config_"
source /splash_builder/parse_yaml.sh
create_variables 


bash -e /splash_builder/libtool.sh "libtool-${config_tools_list__libtool__version}.tar.xz"
bash -e /splash_builder/gdbm.sh "gdbm-${config_tools_list__gdbm__version}.tar.gz"
bash -e /splash_builder/gperf.sh "gperf-${config_tools_list__gperf__version}.tar.gz"
bash -e /splash_builder/expat.sh "expat-${config_tools_list__expat__version}.tar.xz"
bash -e /splash_builder/inetutils.sh "inetutils-${config_tools_list__inetutils__version}.tar.xz"
bash -e /splash_builder/less.sh "less-${config_tools_list__less__version}.tar.gz"
bash -e /splash_builder/perl-pass-2.sh "perl-${config_tools_list__perl__version}.tar.xz"
bash -e /splash_builder/xmlparser.sh "XML-Parser-${config_tools_list__xml_parser__version}.tar.gz"
bash -e /splash_builder/intltool.sh "intltool-${config_tools_list__intltool__version}.tar.gz"
bash -e /splash_builder/autoconf.sh "autoconf-${config_tools_list__autoconf__version}.tar.xz"
bash -e /splash_builder/automake.sh "automake-${config_tools_list__automake__version}.tar.xz"
bash -e /splash_builder/openssl.sh "openssl-${config_tools_list__openssl__version}.tar.gz"
bash -e /splash_builder/kmod.sh "kmod-${config_tools_list__kmod__version}.tar.xz"
bash -e /splash_builder/libelf.sh "elfutils-${config_tools_list__elfutils__version}.tar.bz2"
bash -e /splash_builder/libffi.sh "libffi-${config_tools_list__libffi__version}.tar.gz"
bash -e /splash_builder/python-pass-2.sh "Python-${config_tools_list__python__version}.tar.xz"
bash -e /splash_builder/wheel.sh "wheel-${config_tools_list__wheel__version}.tar.gz"
bash -e /splash_builder/ninja.sh "ninja-${config_tools_list__ninja__version}.tar.gz"
bash -e /splash_builder/meson.sh "meson-${config_tools_list__meson__version}.tar.gz"
bash -e /splash_builder/coreutils.sh "coreutils-${config_tools_list__coreutils__version}.tar.xz"
bash -e /splash_builder/check.sh "check-${config_tools_list__check__version}.tar.gz"
bash -e /splash_builder/diffutils.sh "diffutils-${config_tools_list__diffutils__version}.tar.xz"
bash -e /splash_builder/gawk.sh "gawk-${config_tools_list__gawk__version}.tar.xz"
bash -e /splash_builder/findutils.sh "findutils-${config_tools_list__findutils__version}.tar.xz"
bash -e /splash_builder/groff.sh "groff-${config_tools_list__groff__version}.tar.gz"
bash -e /splash_builder/grub.sh "grub-${config_tools_list__grub__version}.tar.xz"
bash -e /splash_builder/gzip.sh "gzip-${config_tools_list__gzip__version}.tar.xz"
bash -e /splash_builder/iproute2.sh "iproute2-${config_tools_list__iproute2__version}.tar.xz"
bash -e /splash_builder/kbd.sh "kbd-${config_tools_list__kbd__version}.tar.xz"
bash -e /splash_builder/libpipeline.sh "libpipeline-${config_tools_list__libpipeline__version}.tar.gz"
bash -e /splash_builder/make.sh "make-${config_tools_list__make__version}.tar.gz"
bash -e /splash_builder/patch.sh "patch-${config_tools_list__patch__version}.tar.xz"
bash -e /splash_builder/tar.sh "tar-${config_tools_list__tar__version}.tar.xz"
bash -e /splash_builder/texinfo-pass-2.sh "texinfo-${config_tools_list__texinfo__version}.tar.xz"
bash -e /splash_builder/vim.sh "vim-${config_tools_list__vim__version}.tar.xz"
bash -e /splash_builder/markupsafe.sh "MarkupSafe-${config_tools_list__markupsafe__version}.tar.gz"
bash -e /splash_builder/jinja2.sh "Jinja2-${config_tools_list__jinja2__version}.tar.gz"
#bash -e /splash_builder/openrc.sh "openrc-${config_tools_list__openrc__version}.tar.gz"
bash -e /splash_builder/systemd.sh "systemd-${config_tools_list__systemd__version}.tar.gz"
bash -e /splash_builder/dbus.sh "dbus-${config_tools_list__dbus__version}.tar.xz"
bash -e /splash_builder/mandb.sh "man-db-${config_tools_list__man_db__version}.tar.xz"
bash -e /splash_builder/procpsng.sh "procps-ng-${config_tools_list__procps_ng__version}.tar.xz"
bash -e /splash_builder/utillinux-pass-2.sh "util-linux-${config_tools_list__util_linux__version}.tar.xz"
bash -e /splash_builder/e2fsprogs.sh "e2fsprogs-${config_tools_list__e2fsprogs__version}.tar.gz"
bash -e /splash_builder/neofetch.sh "neofetch-${config_tools_list__neofetch__version}.tar.gz"
bash -e /splash_builder/linux.sh "linux-${config_tools_list__linux__version}.tar.xz"

source /config_chroot.sh

# Cleanup system
rm -rf /tmp/*
find /usr/lib /usr/libexec -name \*.la -delete
find /usr -depth -name $(uname -m)-splashos-linux-gnu\* | xargs rm -rf



