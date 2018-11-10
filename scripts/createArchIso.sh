./sPacman.sh make squashfs-tools libisoburn dosfstools patch lynx devtools git
./sGit.sh git://projects.archlinux.org/archiso.git
cd archiso
make install
cd ../
#rm -rf archiso
rm -rf ~/liveInstall
mkdir ~/liveInstall
cp -r /usr/share/archiso/configs/releng/*  ~/liveInstall
mkdir ~/liveInstall/airootfs/root/installScripts
cp -r ../* ~/liveInstall/airootfs/root/installScripts
#cd ~/liveInstall
cd networking/
./startWPA2Wireless.sh
cd ../
dhcpcd
sleep 3
echo "ip lease"
savedDirectory=$(pwd)
networking/tableOff.sh
networking/linkup.sh
cd ~/liveInstall
./build.sh -v
cd $savedDirectory
networking/tableOn.sh
networking/linkdown.sh

