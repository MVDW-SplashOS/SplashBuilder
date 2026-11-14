
# Resetting Build Enviroment

echo "Resetting building enviroment."


find ./sources -maxdepth 1 -mindepth 1 -type d -exec rm -rf '{}' \;


rm -rf $splash_partition_root/*

# Remove build recovery state (a fresh build starts from scratch)
rm -rf $splash_partition_root/.build_state $splash_partition_root/.build_snapshot

mkdir -pv $splash_partition_root/{etc,var,lib64,tools} $splash_partition_root/usr/{bin,lib,sbin}

for i in bin lib sbin; do
  ln -sv usr/$i $splash_partition_root/$i
done


#chown -v splashbuilder -R ./sources
#chmod -v 777 -R ./sources
echo "Success resetting build enviroment."
