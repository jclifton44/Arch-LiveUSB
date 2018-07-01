cd /mnt/scripts/networking
./startWPA2Wireless.sh
dhcpcd
cd /mnt
sed "/^##.*/d" /mnt/sslMirrorList  > /mnt/onlyMirrors
sed "/^\s*$/d" /mnt/onlyMirrors > /mnt/mirrors
echo "#RandomMirror" >> /mnt/mirrors
randServer=$(/mnt/scripts/getRandomMirror.sh)
sed "s@#RandomMirror@Server = $randServer@" /mnt/mirrors > /etc/pacman.d/mirrorList
#sed "s/#Server/Server/" sslMirrorList > /etc/pacman.d/mirrorList
#cp sslMirrorList /etc/pacman.d/mirrorlist
cp pacman.conf /etc/pacman.conf
find / -name asdf
pacman-key --init
pacman-key --populate archlinux
/mnt/scripts/networking/tableOff.sh
pacman -Syy
pacman -S $@
#/mnt/scripts/pac.sh iw dialog efibootmgr grub
/mnt/scripts/networking/tableOn.sh
/mnt/scripts/networking/linkdown.sh



