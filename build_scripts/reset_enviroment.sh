
# Resetting Build Enviroment

echo "Resetting building enviroment."


find ./sources -maxdepth 1 -mindepth 1 -type d -exec rm -rf '{}' \;


rm -rf $splash_partition_root/*

mkdir -pv $splash_partition_root/{etc,var,lib64,tools} $splash_partition_root/usr/{bin,lib,sbin}

for i in bin lib sbin; do
  ln -sv usr/$i $splash_partition_root/$i
done


chown -v splashbuilder $splash_partition_root/{usr{,/*},lib64,lib,var,etc,bin,sbin,tools}


chown -v splashbuilder -R ./sources
chmod -v 777 -R ./sources
echo "Success resetting build enviroment."
