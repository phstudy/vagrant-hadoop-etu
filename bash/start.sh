#!/usr/bin/env bash

declare -a ips=( '192.168.1.80' '192.168.1.81' '192.168.1.82' '192.168.1.83' '192.168.1.84' )
declare -a hostnames=( 'nfs' 'hadoop1' 'hadoop2' 'hadoop3' 'hadoop4' )

for ((i=0;i<${#ips[@]};++i)); do
	echo "set hostname of ${ips[i]} to ${hostnames[i]} into /etc/sysconfig/network"

	ssh-copy-id root@${ips[i]}
	ssh root@${ips[i]} 'bash -s' < change_hostname.sh "${hostnames[i]}" "\"${ips[@]}\"" "\"${hostnames[@]}\""
	ssh-copy-id root@${hostnames[i]}
done

exit 0