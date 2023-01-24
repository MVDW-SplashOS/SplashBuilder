echo "Resetting building enviroment."




source ./build_scripts/prepare/bash_enviroment.sh

echo ${splash_partition_root:?}

rm -rf $splash_partition_root/*

mkdir -pv $splash_partition_root/{etc,var,lib64,tools} $splash_partition_root/usr/{bin,lib,sbin}

for i in bin lib sbin; do
  ln -sv usr/$i $splash_partition_root/$i
done


chown -v splashbuilder $splash_partition_root/{usr{,/*},lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64) chown -v splashbuilder $splash_partition_root/lib64 ;;
esac

chown -v splashbuilder -R ./sources
chmod -v 777 -R ./sources
echo "Success resetting build enviroment."
