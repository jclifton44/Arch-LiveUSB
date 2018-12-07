apt-get install python3.6
apt-get install python3-dev python3-pip libffi-dev libssl-dev
pip3 install mitmproxy
requiredVersion="3.6.1"
sed i "/# END OPENVPN.*/ a -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080" /etc/ufw/before.rules
sed i "/# END OPENVPN.*/ a -A PREROUTING -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 8080" /etc/ufw/before.rules
SAVED_DIRECTORY=$(pwd)
cp $HOME/.mitmproxy/mitmproxy-ca-cert.cer /var/www/html/hosted/ 
echo "rm /var/www/html/hosted/mitmproxy-ca-cert.cer" | at now + 5 minutes
wget https://www.python.org/ftp/python/$requiredVersion/Python-$requiredVersion.tgz
tar xzf Python-$requiredVersion.tgz
mkdir /opt
cp -r Python-$requiredVersion /opt/
cd /opt/Python-$requiredVersion
./configure
make
make install
rm /usr/bin/python
ln /opt/Python-$requiredVersion/python3.6 /usr/bin/python
