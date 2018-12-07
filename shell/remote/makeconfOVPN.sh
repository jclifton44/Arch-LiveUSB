KEY_DIRECTORY="$HOME/ca-dir/keys"
OUTPUT_DIRECTORY="$HOME/client-configs/files"
BASE_CONFIG="$HOME/client-configs/base.conf"

cat ${BASE_CONFIG} \
	<(echo -e '<ca>') \
	${KEY_DIRECTORY}/ca.crt \
	<(echo -e '</ca>\n<cert>') \
	${KEY_DIRECTORY}/${1}.crt \
	<(echo -e '</cert>\n<key>') \
	${KEY_DIRECTORY}/${1}.key \
	<(echo -e '</key>\n<tls-auth>') \
	${KEY_DIRECTORY}/ta.key \
	<(echo -e '</tls-auth>') \
	> $OUTPUT_DIRECTORY/${1}.ovpn
