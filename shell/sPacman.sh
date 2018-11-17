echo "Securely installing ${@:1}"
startWPA2Wireless
dhcpcd
sleep 3
sed "/^##.*/d" /etc/conf/sslMirrorList  > /etc/conf/onlyMirrors
sed "/^\s*$/d" /etc/conf/onlyMirrors > /etc/conf/mirrors
echo "#RandomMirror" >> /etc/conf/mirrors
randServer=$(getRandomMirror)
sed "s@#RandomMirror@Server = $randServer@" /etc/conf/mirrors > /etc/pacman.d/mirrorList
#sed "s/#Server/Server/" sslMirrorList > /etc/pacman.d/mirrorList
#cp sslMirrorList /etc/pacman.d/mirrorlist
cp /etc/conf/pacman.conf /etc/pacman.conf
find / -name $RANDOM
pacman-key --init
pacman-key --populate archlinux
tableOff
linkup
pacman -Sy ${@:1}
tableOn
linkdown



