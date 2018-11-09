echo "Securely installing ${@:1}"
cd networking
./startWPA2Wireless.sh
cd ../
sed "/^##.*/d" ../sslMirrorList  > ../onlyMirrors
sed "/^\s*$/d" ../onlyMirrors > ../mirrors
echo "#RandomMirror" >> ../mirrors
randServer=$(sh getRandomMirror.sh)
sed "s@#RandomMirror@Server = $randServer@" ../mirrors > /etc/pacman.d/mirrorList
#sed "s/#Server/Server/" sslMirrorList > /etc/pacman.d/mirrorList
#cp sslMirrorList /etc/pacman.d/mirrorlist
cp ../pacman.conf /etc/pacman.conf
find / -name $RANDOM
pacman-key --init
pacman-key --populate archlinux
networking/tableOff.sh
networking/linkup.sh
pacman -Sy ${@:1}
networking/tableOn.sh
networking/linkdown.sh



