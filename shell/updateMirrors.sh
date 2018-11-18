directory=$(pwd)

sleep 10
cd $directory
wget -O /etc/shell/sslMirrorList https://www.archlinux.org/mirrorlist/all/https/
if [ $(wc -l /etc/shell/sslMirrorList | awk '{print $1}') == "0" ] 
then
	cp /etc/shell/sslMirrorListBackup /etc/shell/sslMirrorList
fi
rm -rf mirrorsList
touch mirrorsList
echo "Server = $(getRandomMirror)" > /etc/shell/mirrorsList

cat /etc/shell/sslMirrorList | grep "Server" > /etc/shell/mirrors
sed "s/#Server/Server/" /etc/shell/mirrors >> /etc/shell/mirrorsList
cp /etc/shell/mirrorsList /etc/pacman.d/mirrorlist
randomMirror=$(getRandomMirror)

echo "Using randomMirror: $randomMirror"
mirrorBase=$(echo "$randomMirror" | sed "s/\$repo\/os\/\$arch//")
echo "Mirror Base: $mirrorBase"

