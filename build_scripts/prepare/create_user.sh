
groupadd splashbuilder
useradd -s /bin/bash -g splashbuilder -m -k /dev/null splashbuilder

passwd splashbuilder

chown -v splashbuilder $splash_partition_root/{usr{,/*},lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64) chown -v splashbuilder $splash_partition_root/lib64 ;;
esac
