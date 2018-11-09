./sPacman.sh make squashfs-tools libisoburn dosfstools patch lynx devtools git
./sGit.sh git://projects.archlinux.org/archiso.git
cd archiso
make install
#rm -rf archiso
mkdir ~/liveInstall
cp -r /usr/share/archiso/configs/releng/*  ~/liveInstall
mkdir ~/liveInstall/installScripts
cp -r ../* ~/liveInstall/installScripts
cd ~/liveInstall
cd networking
./startWPA2Wireless.sh
cd ../
dhcpcd
sleep 3
echo "ip lease"
networking/linkup.sh
networking/tableOff.sh
./build.sh -v
networking/linkdown.sh
networking/tableOn.sh

