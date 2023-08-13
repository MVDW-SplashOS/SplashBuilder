FILE=$1

echo "-------------------------------------------------------"
echo "Processing $FILE"
echo "-------------------------------------------------------"
sleep 1

cd $DIST_ROOT/sources
echo "Extracting..."
tar --overwrite -xvf  $FILE
DIR=$(echo $FILE | awk -F"\\\\.t" '{print $1}')
cd $DIR

