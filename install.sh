
# timedatectl set-ntp true
# fdisk -l
#/dev/sda2 EFI
#/dev/sda6 root partition 
#/dev/sda7 swap partition
efiPart='/dev/sda2'
rootPart='/dev/sda6'
swapPart='/dev/sda7'
echo "Installing with following partition scheme:"
echo "EFI Partition -> $efiPart"
echo "swap Partition -> $swapPart"
echo "root Partition -> $rootPart"
sleep 6
echo ""
echo "Installing Arch Linux"
echo "---------------------"
echo ""
sleep 3
mkfs.ext4 $rootPart

#mkfs.fat -F32 /dev/sda2
mkdir /iomnt
mount $rootPart  /iomnt
mkdir /iomnt/boot
mount $efiPart /iomnt/boot
rm -rf /iomnt/boot/vmlinuz-linux
rm -rf /iomnt/boot/initramfs-linux.img
cd /mnt/scripts/networking
./startWPA2Wireless.sh
dhcpcd
sleep 10
cd /mnt
sed "s/#RandomMirror/Server = $(./scripts/getRandomMirror.sh)/" /mnt/sslMirrorList> /etc/pacman.d/commentedMirrorList
sed "s/#Server/Server/" /etc/pacman.d/commentedMirrorList > /etc/pacman.d/mirrorList
cp sslMirrorList /etc/pacman.d/mirrorlist
cp pacman.conf /etc/pacman.conf
find / -name asdf
pacman-key --init
pacman-key --populate archlinux
/mnt/scripts/networking/tableOff.sh
/mnt/scripts/pac.sh iw dialog efibootmgr grub
/mnt/scripts/networking/tableOn.sh
/mnt/scripts/networking/linkdown.sh
genfstab -U /iomnt >> /iomnt/etc/fstab
cp preinstall.sh /iomnt/preinstall.sh
arch-chroot /iomnt ./preinstall.sh
mount /dev/sda2 /boot
stringHints=$(grub-probe --target=hints_string /boot/EFI/Microsoft/Boot/bootMicrosoft.efi)
fsUUID=$(grub-probe --target=fs_uuid /boot/EFI/Microsoft/Boot/bootMicrosoft.efi)
sed "s/#MicrosoftHints/search --fs-uuid --set=root $stringHints $fsUUID" grub.cfg > /boot/grub/grub.cfg

umount $efiPart
umount $rootPart
#umount -al 
echo 'Reboot to access your new Arch OS installation'
echo '->reboot
->shutdown now'
#reboot
