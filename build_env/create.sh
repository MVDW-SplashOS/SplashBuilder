set -e

echo "Dist Root: ${DIST_ROOT:?}"
echo "LFS: ${LFS:?}"

#if ! test $(whoami) == "distbuild" ; then
#    echo "Must run as distbuild!"
#    exit -1
#fi

echo "Creating build environment..."
cd $DIST_ROOT/build_env

# Include and parse yaml script
export yaml_file=$DIST_ROOT/build_env/config.yml
export yaml_prefix="config_"
source $DIST_ROOT/build_env/build_scripts/includes/parse_yaml.sh
create_variables #required function in the parse_yaml.sh


# Remove comment to check variables
#parse_yaml $DIST_ROOT/build_env/config.yml "config_"

bash -e build_scripts/binutils-pass-1.sh "binutils-${config_tools_list__binutils__version}.tar.xz"
bash -e build_scripts/gcc-pass-1.sh "gcc-${config_tools_list__gcc__version}.tar.xz"
bash -e build_scripts/linux-headers.sh "linux-${config_tools_list__linux__version}.tar.xz"
bash -e build_scripts/glibc.sh "glibc-${config_tools_list__glibc__version}.tar.xz"
bash -e build_scripts/libstdcpp-pass-1.sh "gcc-${config_tools_list__gcc__version}.tar.xz"
bash -e build_scripts/m4.sh "m4-${config_tools_list__m4__version}.tar.xz"
bash -e build_scripts/ncurses.sh "ncurses-${config_tools_list__ncurses__version}.tar.gz"
bash -e build_scripts/bash.sh "bash-${config_tools_list__bash__version}.tar.gz"
bash -e build_scripts/coreutils.sh "coreutils-${config_tools_list__coreutils__version}.tar.xz"
bash -e build_scripts/diffutils.sh "diffutils-${config_tools_list__diffutils__version}.tar.xz"
bash -e build_scripts/file.sh "file-${config_tools_list__file__version}.tar.gz"
bash -e build_scripts/findutils.sh "findutils-${config_tools_list__findutils__version}.tar.xz"
bash -e build_scripts/gawk.sh "gawk-${config_tools_list__gawk__version}.tar.xz"
bash -e build_scripts/grep.sh "grep-${config_tools_list__grep__version}.tar.xz"
bash -e build_scripts/gzip.sh "gzip-${config_tools_list__gzip__version}.tar.xz"
bash -e build_scripts/make.sh "make-${config_tools_list__make__version}.tar.gz"
bash -e build_scripts/patch.sh "patch-${config_tools_list__patch__version}.tar.xz"
bash -e build_scripts/sed.sh "sed-${config_tools_list__sed__version}.tar.xz"
bash -e build_scripts/tar.sh "tar-${config_tools_list__tar__version}.tar.xz"
bash -e build_scripts/xz.sh "xz-${config_tools_list__xz__version}.tar.xz"
bash -e build_scripts/binutils-pass-2.sh "binutils-${config_tools_list__binutils__version}.tar.xz"
bash -e build_scripts/gcc-pass-2.sh "gcc-${config_tools_list__gcc__version}.tar.xz"

#sudo -E build_scripts/build-chroot.sh

echo "DONE!"
