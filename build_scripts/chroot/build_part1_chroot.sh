set -e

echo "SplashOS Chroot Setup"


touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp

echo ""


export MAKEFLAGS="-j$(nproc)"

#reset enviroment
find /sources -maxdepth 1 -mindepth 1 -type d -exec rm -rf '{}' \;


export yaml_file=/config.yml
export yaml_prefix="config_"
source /splash_builder/parse_yaml.sh
create_variables 

# Building temporarly tools
bash -e /splash_builder/gettext-pass-1.sh "gettext-${config_tools_list__gettext__version}.tar.xz"
bash -e /splash_builder/bison-pass-1.sh "bison-${config_tools_list__bison__version}.tar.xz"
bash -e /splash_builder/perl-pass-1.sh "perl-${config_tools_list__perl__version}.tar.xz"
bash -e /splash_builder/python-pass-1.sh "Python-${config_tools_list__python__version}.tar.xz"
bash -e /splash_builder/texinfo-pass-1.sh "texinfo-${config_tools_list__texinfo__version}.tar.xz"
bash -e /splash_builder/utillinux-pass-1.sh "util-linux-${config_tools_list__util_linux__version}.1.tar.xz"
bash -e /splash_builder/cleanup.sh


# Building final tools
bash -e /splash_builder/bas.sh #TODO: Finish the BAS package manager 
bash -e /splash_builder/manpages.sh "man-pages-${config_tools_list__man_pages__version}.tar.xz"
bash -e /splash_builder/ianaetc.sh "iana-etc-${config_tools_list__iana_etc__version}.tar.gz"
bash -e /splash_builder/glibc.sh "glibc-${config_tools_list__glibc__version}.tar.xz"
bash -e /splash_builder/zlib.sh "zlib-${config_tools_list__zlib__version}.tar.xz"
bash -e /splash_builder/bzip2.sh "bzip2-${config_tools_list__bzip2__version}.tar.gz"
bash -e /splash_builder/xz.sh "xz-${config_tools_list__xz__version}.tar.xz"
bash -e /splash_builder/zstd.sh "zstd-${config_tools_list__zstd__version}.tar.gz"
bash -e /splash_builder/file.sh "file-${config_tools_list__file__version}.tar.gz"
bash -e /splash_builder/readline.sh "readline-${config_tools_list__readline__version}.tar.gz"
bash -e /splash_builder/m4.sh "m4-${config_tools_list__m4__version}.tar.xz"
bash -e /splash_builder/bc.sh "bc-${config_tools_list__bc__version}.tar.xz"
bash -e /splash_builder/flex.sh "flex-${config_tools_list__flex__version}.tar.gz"
bash -e /splash_builder/tcl.sh "tcl${config_tools_list__tcl__version}-src.tar.gz"
bash -e /splash_builder/expect.sh "expect${config_tools_list__expect__version}.tar.gz"
bash -e /splash_builder/dejagnu.sh "dejagnu-${config_tools_list__dejagnu__version}.tar.gz"
bash -e /splash_builder/binutils.sh "binutils-${config_tools_list__binutils__version}.tar.xz"
bash -e /splash_builder/gmp.sh "gmp-${config_tools_list__gmp__version}.tar.xz"
bash -e /splash_builder/mpfr.sh "mpfr-${config_tools_list__mpfr__version}.tar.xz"
bash -e /splash_builder/mpc.sh "mpc-${config_tools_list__mpc__version}.tar.gz"
bash -e /splash_builder/attr.sh "attr-${config_tools_list__attr__version}.tar.gz"
bash -e /splash_builder/acl.sh "acl-${config_tools_list__acl__version}.tar.xz"
bash -e /splash_builder/libcap.sh "libcap-${config_tools_list__libcap__version}.tar.xz"
bash -e /splash_builder/shadow.sh "shadow-${config_tools_list__shadow__version}.tar.xz"
bash -e /splash_builder/gcc.sh "gcc-${config_tools_list__gcc__version}.tar.xz"
bash -e /splash_builder/pkgconfig.sh "pkg-config-${config_tools_list__pkg_config__version}.tar.gz"
bash -e /splash_builder/ncurses.sh "ncurses-${config_tools_list__ncurses__version}.tar.gz"
bash -e /splash_builder/sed.sh "sed-${config_tools_list__sed__version}.tar.xz"
bash -e /splash_builder/psmisc.sh "psmisc-${config_tools_list__psmisc__version}.tar.xz"
bash -e /splash_builder/gettext-pass-2.sh "gettext-${config_tools_list__gettext__version}.tar.xz"
bash -e /splash_builder/bison-pass-2.sh "bison-${config_tools_list__bison__version}.tar.xz"
bash -e /splash_builder/grep.sh "grep-${config_tools_list__grep__version}.tar.xz"
bash -e /splash_builder/bash.sh "bash-${config_tools_list__bash__version}.tar.gz"

cat << EOF | exec /usr/bin/bash --login
./build_part2_chroot.sh
EOF










