set -e

echo "SplashOS Chroot Setup"


touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp

echo ""

export yaml_file=/config.yml
export yaml_prefix="config_"
source /splash_builder/parse_yaml.sh
create_variables 

bash -e /splash_builder/gettext.sh "gettext-${config_tools_list__gettext__version}.tar.xz"
bash -e /splash_builder/bison.sh "bison-${config_tools_list__bison__version}.tar.xz"
bash -e /splash_builder/perl.sh "perl-${config_tools_list__perl__version}.tar.xz"
bash -e /splash_builder/python.sh "Python-${config_tools_list__python__version}.tar.xz"
bash -e /splash_builder/texinfo.sh "texinfo-${config_tools_list__texinfo__version}.tar.xz"
bash -e /splash_builder/utillinux.sh "util-linux-${config_tools_list__util_linux__version}.tar.xz"
bash -e /splash_builder/cleanup.sh
