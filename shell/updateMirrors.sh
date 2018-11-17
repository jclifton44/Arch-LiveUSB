directory=$(pwd)

sleep 10
cd $directory
wget -O /etc/conf/sslMirrorList https://www.archlinux.org/mirrorlist/all/https/
if [ $(wc -l /etc/conf/sslMirrorList | awk '{print $1}') == "0" ] 
then
	cp /etc/conf/sslMirrorListBackup /etc/conf/sslMirrorList
fi
rm -rf mirrorsList
touch mirrorsList
echo "Server = $(getRandomMirror)" > /etc/conf/mirrorsList

cat /etc/conf/sslMirrorList | grep "Server" > /etc/conf/mirrors
sed "s/#Server/Server/" /etc/conf/mirrors >> /etc/conf/mirrorsList
cp /etc/conf/mirrorsList /etc/pacman.d/mirrorlist
randomMirror=$(getRandomMirror)

echo "Using randomMirror: $randomMirror"
mirrorBase=$(echo "$randomMirror" | sed "s/\$repo\/os\/\$arch//")
echo "Mirror Base: $mirrorBase"

