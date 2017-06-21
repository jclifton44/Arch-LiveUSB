
# timedatectl set-ntp true
# fdisk -l
#/dev/sda2 EFI
#/dev/sda6 root partition 
#/dev/sda7 swap partition
mkfs.ext4 /dev/sda6
mkfs.fat -F32 /dev/sda2
mkdir /iomnt
mount /dev/sda6  /iomnt
mkdir /iomnt/boot
mount /dev/sda2 /mnt/boot
cd /mnt/scripts/networking
./startWPA2Wireless.sh
cd /mnt
/mnt/scripts/networking/tableOff.sh
pacstrap /iomnt base base-devel iw wpa_supplicant dialog
/mnt/scripts/networking/tableOn.sh
/mnt/scripts/networking/linkdown.sh
genfstab -U /iomnt >> /iomnt/etc/fstab
# arch-chroot /mnt
