
cd networking/
./startWPA2Wireless.sh
cd ../
dhcpcd
sleep 3
echo "ip lease"
networking/tableOff.sh
networking/linkup.sh
curl -C - -o ver https://mirrors.acm.wpi.edu/archlinux/iso/latest/md5sum.txt
version=$(cat ver | grep linux-2 | sed -s 's/.*archlinux-//g' | sed -s 's/-.*//g')
echo "Latest Version: $version"
if [ $2 == "-c" ];
then
	networking/tableOn.sh
	networking/linkdown.sh
	#make custom iso, burn it.
	./createArchIso.sh 
        dd bs=4M if=archCustom.iso of=$1 status=progress oflag=sync
else
	if [ ! -e archlinux.*.iso ];
	then
		curl -C - -o archlinux-$version-x86_64.iso https://mirrors.acm.wpi.edu/archlinux/iso/$version/archlinux-$version-x86_64.iso
		curl -C - -o archlinux-$version-x86_64.iso.sig https://mirrors.acm.wpi.edu/archlinux/iso/$version/archlinux-$version-x86_64.iso.sig
		networking/tableOn.sh
		networking/linkdown.sh	
		gpg --keyserver-options auto-key-retrieve --verify archlinux-$version-x86_64.iso.sig
	else
		version=$(ls -la | grep archlinux.*x86_64.iso$ | sed -s 's/.*archlinux-//g' | sed -s 's/-.*$//g')
		curl -C - -o archlinux-$version-x86_64.iso.sig https://mirrors.acm.wpi.edu/archlinux/iso/$version/archlinux-$version-x86_64.iso.sig
		networking/tableOn.sh
		networking/linkdown.sh
		gpg --keyserver-options auto-key-retrieve --verify archlinux-$version-x86_64.iso.sig
	fi
	if [ $? -eq 0 ];
	then
		echo "GPG - Gnu Privacy Gaurd Verified"
		echo "Creating USB bootable"
		dd bs=4M if=archlinux-2018.10.01-x86_64.iso of=$1 status=progress oflag=sync

	else
		echo "GPG - Not Verifiable"
		echo "Exiting USB imaging tool"
		exit
	fi

fi
