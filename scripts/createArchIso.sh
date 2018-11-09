./sPacman.sh make squashfs-tools libisoburn dosfstools patch lynx devtools git
./sGit.sh git://proects.archlinux.org/archiso.git
cd archiso
make install
#rm -rf archiso
mkdir ~/liveInstall
cp -r /usr/shar/archiso/configs/releng/*  ~/liveInstall
mkdir ~/liveInstall/installScripts
cp -r * ../* ~/liveInstall/installScripts

