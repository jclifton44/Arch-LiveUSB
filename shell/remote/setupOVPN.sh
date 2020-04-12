apt-get update
apt-get install openvpn easy-rsa
SAVED_DIRECTORY=$(pwd)
OVPN_DIRECTORY="$HOME/ca-dir"
CLIENT_NAME="jcovpn"
SERVER_NAME="jeremy-clifton-vps"
make-cadir $OVPN_DIRECTORY
sed -i "s/export KEY_COUNTRY.*/export KEY_COUNTRY=\"US\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_PROVINCE.*/export KEY_PROVINCE=\"CA\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_CITY.*/export KEY_CITY=\"San Jose\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_ORG.*/export KEY_ORG=\"jeremy-clifton.com\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_EMAIL.*/export KEY_EMAIL=\"gservice341@gmail.com\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_OU.*/export KEY_OU=\"jcovpn\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_NAME.*/export KEY_NAME=\"$SERVER_NAME\"/" $OVPN_DIRECTORY/vars
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
numClients=-1
while [[ $numClients -le 0 ]]; do
	read -p "How many clients will there be? " numClients
done
echo "There will be $numClients clients"
for ((count=1; count<=$numClients; count++)); do
	./build-key ${CLIENT_NAME}${count} #build client key
done

cd keys
cp ca.crt $SERVER_NAME.crt $SERVER_NAME.key ta.key dh2048.pem /etc/openvpn
cd ../
gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz | tee /etc/openvpn/server.conf
sed -i "s/;tls-auth ta.key 0.*/tls-auth ta.key 0 #This file is secret/" /etc/openvpn/server.conf
sed -i '/tls-auth.*/ a key-direction 0' /etc/openvpn/server.conf
sed -i "s/;cipher AES-128-CBC/cipher AES-128-CBC/" /etc/openvpn/server.conf
sed -i "/cipher AES.*/ a auth SHA256" /etc/openvpn/server.conf
sed -i "s/;user nobody/user nobody/" /etc/openvpn/server.conf
sed -i "s/;group nogroup/group nogroup/" /etc/openvpn/server.conf
sed -i "s/;push \"redirect-gateway def1 bypass-dhcp\"/push \"redirect-gateway def1 bypass-dhcp\"/" /etc/openvpn/server.conf
sed -i "s/;push \"dhcp-option DNS .*/push \"dhcp-option DNS 1.1.1.1\"/" /etc/openvpn/server.conf
sed -i "s/cert server.crt/cert $SERVER_NAME.crt/" /etc/openvpn/server.conf
sed -i "s/key server.key/key $SERVER_NAME.key/" /etc/openvpn/server.conf
sed -i "s/server 10.8.0.0 255.255.255.0/server 10.7.0.0 255.255.255.0/" /etc/openvpn/server.conf
sed -i "s/;topology subnet/topology subnet/" /etc/openvpn/server.conf
sed -i "s/;client-config-dir ccd/client-config-dir client-configs/" /etc/openvpn/server.conf
mkdir /etc/openvpn/client-configs
sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
sysctl -p
DEFAULT_INTERFACE=$(ip route | grep default | awk '{ print $5}';)
cat /etc/ufw/before.rules | grep "START OPENVPN RULES"
if [ $? -eq 0 ];
then
	echo "/etc/ufw/before.rules contains routing info"
else
	echo "Updating /etc/ufw/before.rules for routing"
	#lineNumber=$(wc -l /etc/ufw/before.rules | gawk '{ print $1}')
	#sed -i "${lineNumber}i# END OPENVPN RULES" /etc/ufw/before.rules
	#sed -i "${lineNumber}i-A POSTROUTING -s 10.7.0.0/8 -o $DEFAULT_INTERFACE -j MASQUERADE" /etc/ufw/before.rules
	#sed -i "${lineNumber}i# Allow traffic from OpenVPN client to $DEVICE_INTERFACE" /etc/ufw/before.rules
	#sed -i "${lineNumber}i:POSTROUTING ACCEPT [0:0]" /etc/ufw/before.rules
	#sed -i "${lineNumber}i*nat" /etc/ufw/before.rules
	#sed -i "${lineNumber}i# NAT table rules" /etc/ufw/before.rules
	#sed -i "${lineNumber}i# START OPENVPN RULES" /etc/ufw/before.rules
	#masquerade for IP TABLES
	#if ufw does not work try:
	#Note: there is already a UFW RULE FOR MASQUERADING
	# Masquerade all traffic from VPN clients -- done in the nat table 
	#\/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ 
    	#iptables -t nat -I POSTROUTING -o eth0 \
        #  -s 10.8.0.0/24 -j MASQUERADE
	echo "# START OPENVPN RULES" >> /etc/ufw/before.rules
	echo "# NAT table rules" >> /etc/ufw/before.rules
	echo "*nat" >> /etc/ufw/before.rules
	echo ":POSTROUTING ACCEPT [0:0]" >> /etc/ufw/before.rules
	echo "# Allow traffic from OpenVPN client to $DEVICE_INTERFACE" >> /etc/ufw/before.rules
	echo "-A POSTROUTING -s 10.7.0.0/8 -o $DEFAULT_INTERFACE -j MASQUERADE" >> /etc/ufw/before.rules
	echo "# END OPENVPN RULES" >> /etc/ufw/before.rules
fi
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
sed -i "s/ca ca.crt//" $HOME/client-configs/base.conf
sed -i "s/key client.key//" $HOME/client-configs/base.conf
sed -i "s/cert client.crt//" $HOME/client-configs/base.conf
if [[ $1 == '-m' ]]; 
then
	sed -i "/# SSL\/TLS parms./ a #NOTE: This client profile will connect to a VPN that is subject to monitoring for HTTP and HTTPS traffic" $HOME/client-configs/base.conf
fi
sed -i "/# SSL\/TLS parms./ a key-direction 1" $HOME/client-configs/base.conf
sed -i "/# SSL\/TLS parms./ a auth SHA256" $HOME/client-configs/base.conf
sed -i "/# SSL\/TLS parms./ a cipher AES-128-CBC" $HOME/client-configs/base.conf

for ((count=1; count<=$numClients; count++)); do
	makeconfOVPN ${CLIENT_NAME}${count}
	echo "ifconfig-push 10.7.0.$((count + 100)) 255.255.255.0" > /etc/openvpn/client-configs/${CLIENT_NAME}${count}
	cp $HOME/client-configs/files/${CLIENT_NAME}${count}.ovpn /var/www/html/hosted/
	echo "rm /var/www/html/hosted/${CLIENT_NAME}${count}.ovpn" | at now + 5 minutes
done


cp $HOME/client-configs/files/*.ovpn /var/www/html/hosted
cd $SAVED_DIRECTORY
systemctl restart openvpn@server
