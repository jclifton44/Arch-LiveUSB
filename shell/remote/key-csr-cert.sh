#for more info: openssl req ?
# openssl req ?
# -new 
#	new request

# -newkey rsa:<bits>
#	create a new key that is <bits> bits long

# -nodes
#	no DES (Data Encryption Standard)

# -keyout
#	keyout file

# -out
# 	Signing request outfile

# This program will create three items
#	- Private key
#	- CSR - Certificate Signging Request
#	- Signed Certificate


# The Private key is not shared and kept on the server.
# The CSR is the public key 
# The Signed Certificate contains the public key 

# The Signed Certificate can be created individually. The certificate would be considered "Self-signed". 
# If the certificate is not self-signed the CSR must be sent to a CA, or Certificate Authority to be signed. 
# The CSR is sent to the certificate authority and, in reply, the certificate authority will send back a signed certificate.


selfSign=""
keySet=""
csrSet=""
certSet=""
DOMAIN_NAME=$1

for i in "$@"
do	
	case $i in
		-s*)
			echo "Creating self-signed certificate"
			selfSign="true"
			shift
		;;
		-key)
			echo "Key Set"
			keySet=$2
			shift
			shift
		;;
		-csr)
			echo "CSR set"
			csrSet=$2
			shift
			shift
		;;
		-cert)
			echo "cert Set"
			certSet=$2
			shift
			shift
		;;
		*)
			shift
		;;

			

esac
done
if [ $DOMAIN_NAME != "" ]
then
	if [ $selfSign == "true" ]
	then
		#Generate a self-signed certificate
		if [ keySet != "" ]
		then
			if [ csrSet != "" ]
			then
				openssl x509 -signkey $keySet -in $DOMAIN_CSR.csr -req -days 365 -out $DOMAIN_NAME.crt
			else
				openssl req -key $keySet -new -x509 -days 365 -out $DOMAIN_NAME.crt
			fi
			echo "Create CSR: $DOMAIN_NAME.csr"
		else
			echo "Creating a self-signed certificate. $DOMAIN_NAME.crt and $DOMAIN_NAME.key"
			openssl req -newkey rsa:2048 -nodes -keyout $DOMAIN_NAME.key -x509 -days 365 -out $DOMAIN_NAME.crt
		fi
		echo "Signing certificate created by you."
		
	else
		#Generate a CSR to send to a CA
		if [ keySet != "" ]
		then
			if [certSet != "" ]
			then
				openssl x509 -in $certSet -signkey $keySet -x509toreq -out $DOMAIN_NAME.csr
			else
				openssl req -key $keySet -new -out $DOMAIN_NAME.csr
			fi
			echo "Create CSR: $DOMAIN_NAME.csr"
		else
			echo "Created CSR and private key: $DOMAIN_NAME.csr and $DOMAIN_NAME.key"
			openssl req -new -newkey rsa:2048 -nodes -keyout $DOMAIN_NAME.key -out $DOMAIN_NAME.csr
		fi
	fi
	
else
	echo "Please specify a domain name"
fi

