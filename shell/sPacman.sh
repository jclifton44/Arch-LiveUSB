echo "Securely installing ${@:1}"
startWPA2Wireless
dhcpcd
sleep 3
sed "/^##.*/d" /etc/shell/sslMirrorList  > /etc/shell/onlyMirrors
sed "/^\s*$/d" /etc/shell/onlyMirrors > /etc/shell/mirrors
echo "#RandomMirror" >> /etc/shell/mirrors
randServer=$(getRandomMirror)
sed "s@#RandomMirror@Server = $randServer@" /etc/shell/mirrors > /etc/pacman.d/mirrorList
#sed "s/#Server/Server/" sslMirrorList > /etc/pacman.d/mirrorList
#cp sslMirrorList /etc/pacman.d/mirrorlist
cp /etc/shell/pacman.conf /etc/pacman.conf
find / -name $RANDOM
pacman-key --init
pacman-key --populate archlinux
tableOff
linkup
pacman -Sy ${@:1}
tableOn
linkdown



