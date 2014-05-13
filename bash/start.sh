#!/usr/bin/env bash

declare -a ips=( '192.168.1.80' '192.168.1.81' '192.168.1.82' '192.168.1.83' '192.168.1.84' )
declare -a hostnames=( 'nfs' 'hadoop1' 'hadoop2' 'hadoop3' 'hadoop4' )

usage() {
    echo "usage: `basename $0` [options]"
    echo "       -c, --change-hostname		change hostname"
    echo "       -s, --change-swappiness		change swappiness"
    echo "       -d, --disable-selinux		disable selinux"
    echo "       -i, --disable-iptables		disable iptables"
    echo "       -p, --permissive-selinux		permissive selinux"
    echo "       -r, --reboot		reboot"
    echo "       -f, --file {script}		execute script on remote server"
    echo "       -C, --command {cmd}		execute cmd on remote server"
    echo "       -h, --help"
    exit 1
}

case "$1" in
-c|--change-hostname)
	for ((i=0;i<${#ips[@]};++i)); do
		echo "set hostname of ${ips[i]} to ${hostnames[i]} into /etc/sysconfig/network"

		ssh-copy-id root@${ips[i]}
		ssh root@${ips[i]} 'bash -s' < change-hostname.sh "${hostnames[i]}" "\"${ips[@]}\"" "\"${hostnames[@]}\""
		ssh-copy-id root@${hostnames[i]}
	done
    shift;;
-s|--disable-swappiness)
	for ((i=0;i<${#ips[@]};++i)); do
		echo "change swappiness on ${ips[i]} to 0"

		ssh root@${ips[i]} 'bash -s' < change-swappiness.sh
	done
	shift;;
-d|--disable-selinux)
	for ((i=0;i<${#ips[@]};++i)); do
		echo "disable selinux on ${ips[i]}"

		ssh root@${ips[i]} 'bash -s' < disable-selinux.sh
	done
	shift;;
-i|--disable-iptables)
	for ((i=0;i<${#ips[@]};++i)); do
		echo "disable iptables on ${ips[i]}"

		ssh root@${ips[i]} 'bash -s' < disable-iptables.sh
	done
	shift;;
-p|--permissive-selinux)
	for ((i=0;i<${#ips[@]};++i)); do
		echo "permissive selinux on ${ips[i]}"

		ssh root@${ips[i]} 'bash -s' < permissive-selinux.sh
	done
	shift;;
-r|--reboot)
	for ((i=0;i<${#ips[@]};++i)); do
		echo "restart ${ips[i]}"

		ssh root@${ips[i]} 'reboot'
	done
	shift;;
-f|--file)
	for ((i=0;i<${#ips[@]};++i)); do
		echo "execute script \`$2\` on ${ips[i]}"

		ssh root@${ips[i]} 'bash -s' < $2
	done
	shift;;
-C|--command)
	for ((i=0;i<${#ips[@]};++i)); do
		echo "execute command \`$2\` on ${ips[i]}"

		ssh root@${ips[i]} $2
	done
	shift;;
-h|--help)
    usage
    shift;;
"")
    usage
    shift
    break;;
esac

exit 0
