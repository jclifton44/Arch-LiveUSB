# Utility to convert your x509 trustable cert into various cert formats.

# Formats
# DER - Distinguished Encoding Rules
#	Binary encoded
#	Extensions: .crt .cer .der
# PEM - Privacy Enhanced Mail
#	ASCII encode
#	Extensions: .pem .crt .cer

# PKCS - Public Key Cryptography Standard
# PKCS[1-15]
#	- PKCS7
#	- Cryptographic Message Syntax Standard
#	- Stores public key and certificate
#	- ASCII encoded
#	- Extensions: .p7b .p7c
#
#	- PKCS12 or PFX
#	- Personal Information Exchange Syntax
#	- Stores private keys and certificates 
#	- Extensions: .p12 .pfx
#
#	- PKCS8
#	- Privte Key Information Syntax Standard
#	- Stores private keys
#	- Encoding:
#	- Extensions: 
#
PEM=""
DER=""
PKCS12=""
PKCS7=""
PKCS8=""

FILE=$1
FILENAME=""
echo "Importing key with filename: $FILE"
echo $FILE | grep "\.cer$" >> /dev/null
if [ $? -eq '0' ]; then
	FILENAME= $(echo $FILE | sed "s/\.cer$//g")
fi

echo $FILE | grep "\.cert$" >> /dev/null
if [ $? -eq '0' ]; then
	FILENAME= $(echo $FILE | sed "s/\.cert$//g")
fi

echo $FILE | grep "\.pem$" >> /dev/null
if [ $? -eq '0' ]; then
	FILENAME= $(echo $FILE | sed "s/\.pem$//g")
fi

echo $FILE | grep "\.der$" >> /dev/null
if [ $? -eq '0' ]; then
	FILENAME= $(echo $FILE | sed "s/\.der$//g")
fi

echo $FILE | grep "\.crt$" >> /dev/null
if [ $? -eq '0' ]; then
	FILENAME= $(echo $FILE | sed "s/\.crt$//g")
fi
echo $FILE | grep "\.pfx$" >> /dev/null
if [ $? -eq '0' ]; then
	FILENAME=$(echo $FILE | sed "s/\.pfx$//g")
fi

echo $FILE | grep "\.p12$" >> /dev/null
if [ $? -eq '0' ]; then
	FILENAME=$(echo $FILE | sed "s/\.p12$//g")
fi

echo $FILE | grep "\.p7b$" >> /dev/null
if [ $? -eq '0' ]; then
	FILENAME= $(echo $FILE | sed "s/\.p7b$//g")
fi

echo $FILE | grep "\.p7c$" >> /dev/null
if [ $? -eq '0' ]; then
	FILENAME= $(echo $FILE | sed "s/\.p7c$//g")
fi

if [ $# -ne '4' ] || [ -z $FILENAME ];
then
	echo "Usage: convertCertFormat <file to conver> <from format> <to format>"
	echo "Formats: der, pem, pkcs7, pkcs8, pkcs12 or pfx"
	
else 
	if [ $2 == 'pem' ] && [ $3 == 'pkcs7' ];
	then
		openssl cr12pkcs7 -nocrl -certfile $FILE -out $FILENAME.p7b	
	fi
fi
for i in "$@"
do	
	case $1 in
		-s*)
			echo "Creating self-signed certificate"
			selfSign="true"
			shift
			continue
		;;
		-key)
			keySet=$2
			shift 2
			continue

		;;
		-csr)
			csrSet=$2
			shift 2
			continue

		;;
		-cert)
			certSet=$2
			shift 2
			continue
		;;
		*)
			echo $1
			shift
			continue
		;;

			

esac
done

