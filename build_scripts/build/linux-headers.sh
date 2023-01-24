set -e

echo ${splash_partition_root:?}
echo ${SPLASHOS_TGT:?}

. ./build_scripts/build/inc-start.sh $1 $(basename $0)

make mrproper

make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $splash_partition_root/usr
pwd
. ./build_scripts/build/inc-start.sh $1 $(basename $0)
