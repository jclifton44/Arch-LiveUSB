# timedatectl set-ntp true
# fdisk -l
#/dev/sda2 EFI
#/dev/sda6 root partition 
#/dev/sda5 swap partition
rootNumber='5'
efiNumber='1'
efiPart="/dev/sda$efiNumber"
rootPart=$(echo "/dev/sda$rootNumber")
swapPart='/dev/sda6'
echo "Installing with following partition scheme:"
echo "EFI Partition -> $efiPart"
echo "swap Partition -> $swapPart"
echo "root Partition -> $rootPart"
sleep 6
echo ""
echo "Installing Arch Linux"
echo "---------------------"
echo 
sleep 3
mkfs.ext4 $rootPart

#mkfs.fat -F32 /dev/sda2
mkdir /iomnt
mount $rootPart  /iomnt
mkdir /iomnt/boot
mount $efiPart /iomnt/boot
rm -rf /iomnt/boot/amd-ucode.img
rm -rf /iomnt/boot/intel-ucode.img
rm -rf /iomnt/boot/vmlinuz-linux
rm -rf /iomnt/boot/initramfs-linux.img
startWPA2Wireless
dhcpcd
sleep 10
cd /mnt
sed "/^##.*/d" /etc/shell/sslMirrorList  > /etc/shell/onlyMirrors
sed "/^\s*$/d" /etc/shell/onlyMirrors > /etc/shell/mirrors
echo "#RandomMirror" >> /etc/shell/mirrors
randServer=$(getRandomMirror)
sed "s@#RandomMirror@Server = $randServer@" /etc/shell/mirrors > /etc/pacman.d/mirrorList
#sed "s/#Server/Server/" sslMirrorList > /etc/pacman.d/mirrorList
#cp sslMirrorList /etc/pacman.d/mirrorlist
cp /etch/shell/pacman.conf /etc/pacman.conf
find / -name asdf
pacman-key --init
pacman-key --populate archlinux
tableOff
linkup
pac iw dialog efibootmgr grub
tableOn
linkdown
mkdir /iomnt/etc
touch /iomnt/etc/fstab
genfstab -U /iomnt >> /iomnt/etc/fstab
cp /etc/shell/preinstall.sh /iomnt/preinstall.sh
arch-chroot /iomnt ./preinstall.sh
#bootloader
umount $rootPart
configureBoot

echo 'Reboot to access your new Arch OS installation'
echo '->reboot
->shutdown now'
#reboot



