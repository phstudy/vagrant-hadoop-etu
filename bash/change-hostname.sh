#!/usr/bin/env bash

OLD_HOSTNAME="$( hostname )"
NEW_HOSTNAME="$1"
declare -a ips=(${2// / })
declare -a hostnames=(${3// / })

if [ -z "$NEW_HOSTNAME" ]; then
 echo -n "Please enter new hostname: "
 read NEW_HOSTNAME < /dev/tty
fi

if [ -z "$NEW_HOSTNAME" ]; then
 echo "Error: no hostname entered. Exiting."
 exit 1
fi

echo "Changing hostname from $OLD_HOSTNAME to $NEW_HOSTNAME..."

hostname "$NEW_HOSTNAME"
sed -i "s/HOSTNAME=.*/HOSTNAME=$NEW_HOSTNAME/g" /etc/sysconfig/network

for ((i=0;i<${#ips[@]};++i)); do
	map="${ips[i]} ${hostnames[i]}"
	echo "set $map into /etc/hosts"
	grep "$map" /etc/hosts >/dev/hosts  || echo "$map" >> /etc/hosts
done

echo "Done."

exit 0