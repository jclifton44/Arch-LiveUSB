cd /mnt/scripts/networking
./startWPA2Wireless.sh
dhcpcd
sleep 1
cd /mnt
sed "s/#RandomMirror/Server = $(./scripts/getRandomMirror.sh)/" /mnt/sslMirrorList> /etc/pacman.d/commentedMirrorList
sed "s/#Server/Server/" sslMirrorList > /etc/pacman.d/mirrorList
#cp sslMirrorList /etc/pacman.d/mirrorlist
cp pacman.conf /etc/pacman.conf
find / -name asdf
pacman-key --init
pacman-key --populate archlinux
/mnt/scripts/networking/tableOff.sh
/mnt/scripts/pac.sh iw dialog efibootmgr grub
/mnt/scripts/networking/tableOn.sh
/mnt/scripts/networking/linkdown.sh
mkdir /iomnt/etc
touch /iomnt/etc/fstab
genfstab -U /iomnt >> /iomnt/etc/fstab
cp preinstall.sh /iomnt/preinstall.sh
arch-chroot /iomnt ./preinstall.sh
mount /dev/sda2 /boot


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
sed "s/#MicrosoftHints/search --fs-uuid --set=root $stringHints $fsUUID/" grub.cfg > /boot/grub/linux.grub.cfg
sed "s/#LinuxRootPartition/linux \/vmlinuz-linux root=\/dev\/sda$rootNumber/" /boot/grub/linux.grub.cfg > /boot/grub/grub.cfg
rm -rf /boot/grub/linux.grub.cfg
#linux /vmlinuz-linux root=/dev/sda4
umount $efiPart
umount $rootPart
#umount -al 
echo 'Reboot to access your new Arch OS installation'
echo '->reboot
->shutdown now'
#reboot



