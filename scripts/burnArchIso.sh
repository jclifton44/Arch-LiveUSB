curl -C - -o ver https://mirrors.acm.wpi.edu/archlinux/iso/latest/md5sum.txt
version=$(cat ver | grep linux-2 | sed -s 's/.*archlinux-//g' | sed -s 's/-.*//g')
echo "Latest Version: $version"
if [ ! -e archlinux.*.iso ];
then
	curl -C - -o archlinux-$version-x86.iso https://mirrors.acm.wpi.edu/archlinux/iso/$version/archlinux-$version-x86_64.iso
	curl -C - -o archlinux-$version-x86.iso.sig https://mirrors.acm.wpi.edu/archlinux/iso/$version/archlinux-$version-x86_64.iso.sig
	gpg --keyserver-options auto-key-retrieve --verify archlinux-$version-x86_64.iso.sig
	if [ $? -eq 0 ];
	then
		echo "GPG - Gnu Privacy Gaurd Verified"
	else
		echo "GPG - Not Verifiable"
		echo "Exiting USB imaging tool"
		exit
	fi
else

fi
