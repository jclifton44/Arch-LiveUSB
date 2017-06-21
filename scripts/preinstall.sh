uname -n
ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime
hwclock --systohc
locale-gen
sh scripts/toggle.sh /etc/locale.sh en_US.UTF -u
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "pepsi-machine" >> /etc/hostname
mkinitcpio -p linux
mount /dev/sda2 /boot
grub-install --efi-directory=/boot
cp /boot/arch/grubx64.efi /boot/EFI/BOOT/BOOTX64.efi
#refind-install --usedefault /dev/sda2
#bootloader code
#this is specific to your computer or your architecture
