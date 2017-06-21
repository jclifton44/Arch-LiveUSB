mount /dev/sda2 /boot
##bootctl --path=/boot install

cp loader.conf /boot/loader/loader.conf
uuid=$(./getUUID.sh)
type=$(./getTYPE.sh)
cp /mnt/arch.conf /boot/loader/entries/arch.conf
echo "options root=PARTUUID=${uuid} rw" >> /boot/loader/entries/arch.conf
