directory=$(pwd)

sleep 10
cd $directory
wget -O /mnt/sslMirrorList https://www.archlinux.org/mirrorlist/all/https/
if [ $(wc -l /mnt/sslMirrorList | awk '{print $1}') == "0" ] 
then
	cp /mnt/sslMirrorListBackup /mnt/sslMirrorList
fi
rm -rf mirrorsList
touch mirrorsList
echo "Server = $(/mnt/scripts/getRandomMirror.sh)" > mirrorsList

cat /mnt/sslMirrorList | grep "Server" > mirrors
sed "s/#Server/Server/" mirrors >> mirrorsList
cp mirrorsList /etc/pacman.d/mirrorlist
randomMirror=$(/mnt/scripts/getRandomMirror.sh)

echo "Using randomMirror: $randomMirror"
mirrorBase=$(echo "$randomMirror" | sed "s/\$repo\/os\/\$arch//")
echo "Mirror Base: $mirrorBase"

