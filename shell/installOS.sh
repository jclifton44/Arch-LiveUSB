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
mount $efiPart /boot


#bootloader


grub-install --target=x86_64-efi --efi-directory=/boot/efi
#cp /boot/EFI/EFI/arch/grubx64.efi /boot/EFI/BOOT/BOOTX64.efi
cp /boot/EFI/Microsoft/Boot/bootmgfw.efi /boot/EFI/Microsoft/Boot/bootMicrosoftCopy.efi
if [ ! -e /boot/EFI/Microsoft/Boot/bootMicrosoft.efi ];
then
	cp /boot/EFI/Microsoft/Boot/bootmgfw.efi /boot/EFI/Microsoft/Boot/bootMicrosoft.efi
else
	file1=$(md5sum /boot/EFI/Microsoft/Boot/bootmgfw.efi | cut -c 1-32)
	file2=$(md5sum /boot/EFI/EFI/arch/grubx64.efi | cut -c 1-32)
	if [ $file1 == $file2 ]; 
	then
			echo "Grub already installed. Reinstalling Arch. Keeping bootMicrosoft.efi."
			echo "If you have problems accessing any other installations refer to OS recovery software."
			sleep 3
	else
			echo "Boot method is not grub. Saving current boot method to bootMicrosoft.efi"
		cp /boot/EFI/Microsoft/Boot/bootmgfw.efi /boot/EFI/Microsoft/Boot/bootMicrosoft.efi
	fi
	
fi
cp /boot/EFI/EFI/arch/grubx64.efi /boot/EFI/Microsoft/Boot/bootmgfw.efi
umount /dev/sdb2
stringHints=$(grub-probe --target=hints_string /boot/EFI/Microsoft/Boot/bootMicrosoft.efi)
fsUUID=$(grub-probe --target=fs_uuid /boot/EFI/Microsoft/Boot/bootMicrosoft.efi)
sed "s|#MicrosoftHints|search --fs-uuid --set=root $stringHints $fsUUID|" /etc/shell/grub.cfg > /boot/grub/linux.grub.cfg
sed "s|#EFIPartition|set root=(hd0,gpt$efiNumber)|" /etc/shell/linux.grub.cfg > /boot/grub/linux.grub.cfg2
sed "s/#LinuxRootPartition/linux \/vmlinuz-linux root=\/dev\/sda$rootNumber/" /boot/grub/linux.grub.cfg2 > /boot/grub/grub.cfg
rm -rf /boot/grub/linux.grub.cfg
rm -rf /boot/grub/linux.grub.cfg2
#linux /vmlinuz-linux root=/dev/sda4
umount $efiPart
umount $rootPart
#umount -al 
echo 'Reboot to access your new Arch OS installation'
echo '->reboot
->shutdown now'
#reboot



