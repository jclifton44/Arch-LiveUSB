./sPacman.sh make squashfs-tools libisoburn dosfstools patch lynx devtools git
git clone git://proects.archlinux.org/archiso.git
cd archiso
make install
mkdir ~/liveInstall
cp -r /usr/shar/archiso/configs/releng/*  ~/liveInstall


