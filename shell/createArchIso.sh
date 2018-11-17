sPacman.sh make squashfs-tools libisoburn dosfstools patch lynx devtools git
sGit.sh git://projects.archlinux.org/archiso.git
cd archiso
make install
cd ../
rm -rf archiso
rm -rf ~/liveInstall
mkdir ~/liveInstall
cp -r /usr/share/archiso/configs/releng/*  ~/liveInstall
mkdir ~/liveInstall/airootfs/root/installScripts
#cp -r ../* ~/liveInstall/airootfs/root/installScripts
#copy the specific scripts needed
#cd ~/liveInstall
startWPA2Wireless
dhcpcd
sleep 3
echo "ip lease"
savedDirectory=$(pwd)
tableOff
linkup
cd ~/liveInstall
./build.sh -v
isoName=$(ls out/)
echo "Moving new iso: $isoName"
cp out/$isoName $savedDirectory/archCustom.iso
cd $savedDirectory
tableOn
linkdown

