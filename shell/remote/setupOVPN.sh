apt-get update
apt-get install openvpn easy-rsa
SAVED_DIRECTORY=$(pwd)
OVPN_DIRECTORY="$HOME/ca-dir"
CLIENT_NAME="jcovpn"
SERVER_NAME="server"
make-cadir $OVPN_DIRECTORY
sed -i "s/export KEY_COUNTRY.*/export KEY_COUNTRY=\"US\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_PROVINCE.*/export KEY_PROVINCE=\"CA\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_CITY.*/export KEY_CITY=\"San Jose\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_ORG.*/export KEY_ORG=\"jeremy-clifton.com\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_EMAIL.*/export KEY_EMAIL=\"gservice341@gmail.com\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_OU.*/export KEY_OU=\"ovpn\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_NAME.*/export KEY_NAME=\"server\"/" $OVPN_DIRECTORY/vars
cd $OVPN_DIRECTORY
source vars
./clean-all
#Example:
#openssl req $BATCH -days $CA_EXPIRE $NODES_REQ -new -newkey rsa:$KEY_SIZE \-x509 -keyout "$CA.key" -out "$CA.crt" -config "$KEY_CONFIG" && \
#	req - utility to generate certificate
#	-days expires in CA_EXPIRE
#	$NODES_REQ no-des (DES - Data Encryption Standard)
#	-nodes, openssl will NOT output a PKCS bundle file of the KEY and CERT
#	-new openssl generates a new certificate request (CSR - certificate signing request)
#	-newkey rsa:$KEY_SIZE openssl generates a new certificate request and RSA key of size $KEY_SIZE (RSA - Rivest Shamir Adleman)
#	RSA - Developed by Ron Rivest, Adi Shamir, Leonard Adleman public key assymetric cryptography
#	-x509 openssl generates a certificate in x509 format. A certificate if a unique fingerprint to attach to and identify a key
#	https://tools.ietf.org/html/rfc4158

./build-ca #build certificate authourity for client and server
./build-key-server $SERVER_NAME #build server key
./build-dh #generate diffie helman number for key exchange
openvpn --genkey --secret keys/ta.key #generate HMAC signature to verify and validated message (HMAC Hash-based Message Authentication Code) 
./build-key $CLIENT_NAME #build client key
cd keys
cp ca.crt $SERVER_NAME.crt $SERVER_NAME.key ta.key dh2048.pem /etc/openvpn
cd ../
gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz | tee /etc/openvpn/server.conf
sed -i "s/;tls-auth ta.key 0.*/tls-auth ta.key 0 #This file is secret/" /etc/openvpn/server.conf
sed -i '/tls-auth.*/ a key-direction 0' /etc/openvpn/server.conf
sed -i "s/;cipher AES-128-CBC/cipher AES-128-CBC/" /etc/openvpn/server.conf
sed -i "s/;auth SHA256/auth SHA256/" /etc/openvpn/server.conf
sed -i "s/;user nobody/user nobody/" /etc/openvpn/server.conf
sed -i "s/;group nogroup/group nogroup/" /etc/openvpn/server.conf
sed -i "s/;push \"redirect-gateway def1 bypass-dhcp\"/push \"redirect-gateway def1 bypass-dhcp\"/" /etc/openvpn/server.conf
sed -i "s/;push \"dhcp-option DNS .*/push \"dhcp-option DNS 1.1.1.1\"/" /etc/openvpn/server.conf
#sed -i "s/cert server.crt/cert $SERVER_NAME.crt/" /etc/openvpn/server.conf
#sed -i "s/key server.key/key $SERVER_NAME.key/" /etc/openvpn/server.conf
#sed -i "s/server 10.8.0.0 255.255.255.0/server 10.7.0.0 255.255.255.0/" /etc/openvpn/server.conf

sed -i "s/#new.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
sysctl -p
DEFAULT_INTERFACE=$(ip route | grep default | awk '{ print $5}';)

sed -i "/#Don't delete these required.*/ a # END OPENVPN RULES" /etc/ufw/before.rules
sed -i "/#Don't delete these required.*/ a COMMIT" /etc/ufw/before.rules
sed -i "/#Don't delete these required.*/ a -A POSTROUTING -s 10.7.0.0/8 -o $DEFAULT_INTERFACE - MASQUERADE" /etc/ufw/before.rules
sed -i "/#Don't delete these required.*/ a # Allow traffic from OpenVPN client to $DEVICE_INTERFACE" /etc/ufw/before.rules
sed -i "/#Don't delete these required.*/ a :POSTROUTING ACCEPT [0:0]" /etc/ufw/before.rules
sed -i "/#Don't delete these required.*/ a *nat" /etc/ufw/before.rules
sed -i "/#Don't delete these required.*/ a # NAT table rules" /etc/ufw/before.rules
sed -i "/#Don't delete these required.*/ a # START OPENVPN RULES" /etc/ufw/before.rules

sed -i "s/DEFAULT_FORWARD_POLICY=\"DROP\"/DEFAULT_FORWARD_POLICY=\"ACCEPT\"/" /etc/default/ufw
ufw allow 1194/udp
ufw disable
ufw enable
systemctl start openvpn@server
systemctl status openvpn@server
systemctl enable openvpn@server
ip addr show tun0
mkdir -p $HOME/client-configs/files
chmod 700 $HOME/client-configs/files
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf $HOME/client-configs/base.conf


sed -i "s/remote my-server-1 1194/remote jeremy-clifton.com 1194/" $HOME/client-configs/base.conf
sed -i "s/;user nobody/user nobody/" $HOME/client-configs/base.conf
sed -i "s/;group nogroup/group nogroup/" $HOME/client-configs/base.conf
sed -i "/key client.key/ a key-direction 1" $HOME/client-configs/base.conf
sed -i "/key client.key/ a auth SHA256" $HOME/client-configs/base.conf
sed -i "/key client.key/ a cipher AES-128-CBC" $HOME/client-configs/base.conf
makeconfOVPN $CLIENT_NAME
cp $HOME/client-configs/files/*.ovpn /var/www/html/hosted
cd $SAVED_DIRECTORY
