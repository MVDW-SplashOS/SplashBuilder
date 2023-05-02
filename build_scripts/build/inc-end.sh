FILE=$1

echo
echo "Cleaning up..."
echo

cd $DIST_ROOT/sources
DIR=$(echo $FILE | awk -F"\\\\.t" '{print $1}')
rm -rf $DIR
cd $DIST_ROOT

echo
echo "Done Processing $FILE"
echo
