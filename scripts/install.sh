
# timedatectl set-ntp true
# fdisk -l
#/dev/sda2 EFI
#/dev/sda6 root partition 
#/dev/sda7 swap partition
mkfs.ext4 /dev/sda6
#mkfs.fat -F32 /dev/sda2
mkdir /iomnt
mount /dev/sda6  /iomnt
mkdir /iomnt/boot
mount /dev/sda2 /iomnt/boot
rm -rf /iomnt/boot/vmlinuz-linux
rm -rf /iomnt/boot/initramfs-linux.img
cd /mnt/scripts/networking
./startWPA2Wireless.sh
dhcpcd
sleep 10
cd /mnt
cp sslMirrorList /etc/pacman.d/mirrorlist
cp pacman.conf /etc/pacman.conf
find / -name asdf
pacman-key --init
pacman-key --populate archlinux
/mnt/scripts/networking/tableOff.sh
/mnt/scripts/networking/pac.sh
/mnt/scripts/networking/tableOn.sh
/mnt/scripts/networking/linkdown.sh
genfstab -U /iomnt >> /iomnt/etc/fstab
cp preinstall.sh /iomnt/preinstall.sh
arch-chroot /iomnt ./preinstall.sh
./install2.sh
