stringHints=$(grub-probe --target=hints_string $1)
echo $stringHints

fsUUID=$(grub-probe --target=fs_uuid $1)
echo $fsUUID
sed "s/#MicrosoftHints/search --fs-uuid --set=root $stringHints $fsUUID/" grub.cfg > /boot/grub/grub.cfg

