directory=$(pwd)

cd /mnt/scripts/networking
./startWPA2Wireless.sh
dhcpcd
sleep 10
cd $directory
arch=$(uname -m)
/mnt/scripts/networking/tableOff.sh
/mnt/scripts/updateMirrors.sh
randomMirror=$(./getRandomMirror.sh)
echo "Using randomMirror: $randomMirror"
mirrorBase=$(echo "$randomMirror" | sed "s/\$repo\/os\/\$arch//")
echo "Mirror Base: $mirrorBase"
communityDB="${mirrorBase}community/os/$arch/community.db"
coreDB="${mirrorBase}core/os/$arch/core.db"
extraDB="${mirrorBase}extra/os/$arch/extra.db"
multilibDB="${mirrorBase}multilib/os/$arch/multilib.db"
wget $coreDB
wget $extraDB
wget $communityDB
if [ $arch == "x86_64" ]
then
	wget $multilibDB
fi
mkdir /var/lib/pacman/sync/

cp *.db /var/lib/pacman/sync/
rm -rf *.db*
cp pacman.conf /etc/pacman.conf
pacman -Sp --noconfirm base base-devel iw dialog grub efibootmgr > packageList
./randomActivity.sh
pacman-key --init
pacman-key --populate archlinux
mkdir /packageInstall
mv packageList /packageInstall
cd /packageInstall
wget -nv -i packageList
#/mnt/scripts/pac.sh "dialog iw efibootmgr grub"
/mnt/scripts/networking/tableOn.sh
/mnt/scripts/networking/linkdown.sh
echo 'Local Installation'
echo '->reboot'

