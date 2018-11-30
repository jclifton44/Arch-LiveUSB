apt-get update
apt-get install openvpn easy-rsa
OVPN_DIRECTORY="~/ca-dir"
make-cadir $OVPN_DIRECTORY
sed -i "s/export KEY_COUNTRY.*/export KEY_COUNTRY=\"US\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_PROVINCE.*/export KEY_PROVINCE=\"CA\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_CITY.*/export KEY_CITY=\"San Jose\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_ORG.*/export KEY_ORG=\"jeremy-clifton.com\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_EMAIL.*/export KEY_EMAIL=\"gservice341@gmail.com\"/" $OVPN_DIRECTORY/vars
sed -i "s/export KEY_OU.*/export KEY_OU=\"ovpn\"/" $OVPN_DIRECTORY/vars

