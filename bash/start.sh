#!/usr/bin/env bash

master_ip='192.168.1.81'
master_hostname='hadoop1'
declare -a ips=( '192.168.1.80' $master_ip '192.168.1.82' '192.168.1.83' '192.168.1.84' )
declare -a hostnames=( 'nfs' $master_hostname 'hadoop2' 'hadoop3' 'hadoop4' )

usage() {
    echo "usage: `basename $0` [options]"
    echo "       -c, --change-hostname		change hostname"
    echo "       -s, --change-swappiness		change swappiness"
    echo "       -d, --disable-selinux		disable selinux"
    echo "       -i, --disable-iptables		disable iptables"
    echo "       -j, --install-oracle-jdk7		install oracle jdk7"
    echo "       -n, --setup-ntp		setup ntp"
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
-n|--setup-ntp)
	for ((i=0;i<${#ips[@]};++i)); do
		echo "setup ntp on ${ips[i]}"

		ssh root@${ips[i]} 'yum -y install ntp ntpdate ntp-doc && chkconfig ntpd on && service ntpd start && ntpdate pool.ntp.org'
	done
	shift;;
-j|--install-oracle-jdk7)
	for ((i=0;i<${#ips[@]};++i)); do
		echo "install oracle jdk7 on ${ips[i]}"

		scp jdk-7u55-linux-x64.rpm root@${ips[i]}:~
		ssh root@${ips[i]} 'yum -y --nogpgcheck localinstall jdk-7u55-linux-x64.rpm'
		ssh root@${ips[i]} 'bash -s' < set-java-home.sh
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
