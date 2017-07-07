fsUUID=$(grub-probe --target=fs_uuid /boot/EFI/Microsoft/Boot/bootMicrosoft.efi)
stringHints=$(grub-probe --target=hints_string /boot/EFI/Microsoft/Boot/bootMicrosoft.efi)
sed "s/#MicrosoftHints/search --fs-uuid --set=root $stringHints $fsUUID/" grub.cfg > file
echo "test"
echo $fsUUID
