uname -n
ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime
hwclock --systohc
locale-gen
sh scripts/toggle.sh /etc/locale.sh en_US.UTF -u
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "pepsi-machine" >> /etc/hostname
mkinitcpio -p linux
umount /dev/sda2
mount /dev/sda2 /boot
grub-install --efi-directory=/boot
cp /boot/EFI/arch/grubx64.efi /boot/EFI/BOOT/BOOTX64.efi
cp /boot/EFI/Microsoft/Boot/bootmgfw.efi /boot/EFI/Microsoft/Boot/bootMicrosoftCopy.efi
cp /boot/EFI/Microsoft/Boot/bootmgfw.efi /boot/EFI/Microsoft/Boot/bootMicrosoft.efi
cp /boot/EFI/arch/grubx64.efi /boot/EFI/Microsoft/Boot/bootmgfw.efi
umount /dev/sdb2
#refind-install --usedefault /dev/sda2
#bootloader code
#this is specific to your computer or your architecture
