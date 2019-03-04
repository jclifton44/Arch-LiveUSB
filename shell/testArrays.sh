declare -A map=([foo]=bar [a a]=no )
declare -A map2=([foo2]=bar2 [aAa]=no1 )
echo ${map[a a]}
echo ${map2[foo2]}
echo ${map2['foo2']}
map2['aAa']=map
echo ${${map2["foo2"]}[foo]}

