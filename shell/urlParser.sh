url=$1
protocol=$(echo $url | sed "s/:\/\/.*$//g")
fqdn=$(echo $url | sed "s/^.*:\/\///g"  | sed "s/\/.*$//g")
path=$(echo $url | sed "s/^.*:\/\///g" | sed "s/^[^\/]*//")
echo "$protocol $fqdn $path"
