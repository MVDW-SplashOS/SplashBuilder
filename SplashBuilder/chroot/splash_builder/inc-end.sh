FILE=$1

echo
echo "Cleaning up..."
echo

cd /sources
DIR=$(echo $FILE | awk -F"\\\\.t" '{print $1}')
DIR=$(echo $DIR | awk -F"\\\\-src" '{print $1}')
#rm -rf $DIR

echo
echo "Done Processing $2"
echo
