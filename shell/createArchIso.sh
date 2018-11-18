sPacman make squashfs-tools libisoburn dosfstools patch lynx devtools git
sGit git://projects.archlinux.org/archiso.git
cd archiso
echo "ARCH ISO ->>>>>>>>>>>>>>>>>>>>>>>>>>>>"
make install
cd ../
rm -rf archiso
rm -rf ~/liveInstall
mkdir ~/liveInstall
cp -r /usr/share/archiso/configs/releng/*  ~/liveInstall
mkdir ~/liveInstall/airootfs/root/installScripts
#cp -r ../* ~/liveInstall/airootfs/root/installScripts
savedDirectory=$(pwd)
cd ~/liveInstall/airootfs/root/installScripts
sGit https://github.com/jclifton44/shell-scripts
cd $savedDirectory
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

