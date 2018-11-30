apt-get update
apt-get install openvpn easy-rsa
SAVED_DIRECTORY=$(pwd)
OVPN_DIRECTORY="$HOME/ca-dir"
make-cadir $OVPN_DIRECTORY
sed -i "s/export KEY_COUNTRY.*/export KEY_COUNTRY=\"US\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_PROVINCE.*/export KEY_PROVINCE=\"CA\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_CITY.*/export KEY_CITY=\"San Jose\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_ORG.*/export KEY_ORG=\"jeremy-clifton.com\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_EMAIL.*/export KEY_EMAIL=\"gservice341@gmail.com\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_OU.*/export KEY_OU=\"ovpn\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_NAME.*/export KEY_NAME=\"jeremy-clifton-vps\"/" $OVPN_DIRECTORY/vars
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
./build-key-server jeremy-clifton-vps #build server key
./build-dh #generate diffie helman number for key exchange
openvpn --genkey --secret keys/ta.key #generate HMAC signature to verify and validated message (HMAC Hash-based Message Authentication Code) 
./build-key #build client key
cd keys
cp ca.crt jeremy-clifton-vps.crt jeremy-clifton-vps.key ta.key dh2048.pem /etc/openvpn
gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz | tee /etc/openvpn/server.conf
sed -i "s/;tls-auth ta.key 0.*/tls-auth ta.key 0 #This file is secret/" /etc/openvpn/server.conf
sed -i '/tls-auth.*/ a key-direction 0' /etc/openvpn/server.conf
sed -i "s/;cipher AED-128-CBC/cipher AED-128-CBC/" /etc/openvpn/server.conf
sed -i "s/;auth SHA256/auth SHA256/" /etc/openvpn/server.conf
sed -i "s/;user nobody/user nobody/" /etc/openvpn/server.conf
sed -i "s/;group nogroup/group nogroup/" /etc/openvpn/server.conf
sed -i "s/;push\"redirect-gateway def1 bypass-dhcp\"/push\"redirect-gateway def1 bypass-dhcp\"/" /etc/openvpn/server.conf
sed -i "s/;push \"dhcp-option DNS .*/push \"dhcp-option DNS 1.1.1.1\"" /etc/openvpn/server.conf
sed -i "s/cert server.crt/cert jeremy-clifton-vps.crt/" /etc/openvpn/server.conf
sed -i "s/key server.key/cert jeremy-clifton-vps.key/" /etc/openvpn/server.conf

sed -i "s/#new.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
sysctl -p



