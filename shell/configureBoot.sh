#bootloader
efiNumber='1'
efiPart="/dev/sda$efiNumber"
rootNumber='5'
rootPart="/dev/sda$rootNumber"
echo "Configuring EFI: $efiPart"
mount $rootPart /mnt
mount $efiPart /boot
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
#umount /dev/sdb2
stringHints=$(grub-probe --target=hints_string /boot/EFI/Microsoft/Boot/bootMicrosoft.efi)
fsUUID=$(grub-probe --target=fs_uuid /boot/EFI/Microsoft/Boot/bootMicrosoft.efi)
sed "s|#MicrosoftHints|search --fs-uuid --set=root $stringHints $fsUUID|" /etc/shell/grub.cfg > /boot/grub/linux.grub.cfg
sed "s/#EFIPartition/set root=(hd0,gpt$efiNumber)/" /boot/grub/linux.grub.cfg > /boot/grub/linux.grub.cfg2
sed "s/#LinuxRootPartition/linux \/vmlinuz-linux root=\/dev\/sda$rootNumber/" /boot/grub/linux.grub.cfg2 > /boot/grub/grub.cfg
cp /etc/shell/boot.example /boot
mkdir /mnt/etc/shell
cp /usr/bin/configureBoot /mnt/etc/shell/
#rm -rf /boot/grub/linux.grub.cfg
#rm -rf /boot/grub/linux.grub.cfg2
#linux /vmlinuz-linux root=/dev/sda4
umount $efiPart
umount $rootPart



