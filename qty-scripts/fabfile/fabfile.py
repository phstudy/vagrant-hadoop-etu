from fabric.api import *
from fabric.utils import *
from fabric.contrib.files import *
from server_util import *
import cfg

site_map = cfg.load_config()
env.user = 'ec2-user'
env.roledefs = site_map


env.key_filename = 'aws_key.pem'

@task
def update_hosts(hostname, ip):
    host_util = hosts(get_lines("/etc/hosts"))
    text = host_util.update(ip, hostname)
    put(tmp(text), '/etc/hosts', use_sudo=True)
    sudo('chown root:root /etc/hosts')

@task
def config_hostname(hostname):
    sed('/etc/sysconfig/network', 'HOSTNAME=.*', 'HOSTNAME=%s' % hostname, use_sudo=True)
    sudo('hostname %s' % hostname)
    pass

@task
def base_install():
    sudo('yum install -y telnet wget nfs-utils')

    sudo('chkconfig rpcbind on')
    sudo('service rpcbind start')

    sudo('chkconfig nfs on')
    sudo('service nfs start')

    for step in range(1,4):
        put('install_scripts/%d.sh' % step)
        sudo('sh %d.sh' % step)

@task
def launch_hdfs():
    put('scripts/start_hdfs.sh')
    sudo('sh start_hdfs.sh')

    def wait_for_listen(port):
        import time
        count = 0
        while count == 0:
            with settings(warn_only=True):
                count = int(run('v=$(netstat -an | grep LISTEN | grep -c :%d) ; echo $v' % port))
            puts('wait for port %d (count: %d)' % (port, count))
            if count == 0:
                time.sleep(10)

    # wait namenode web-ui, rpc
    wait_for_listen(50070)
    wait_for_listen(8020)

    # wait datanode ports
    wait_for_listen(50010)
    wait_for_listen(50020)
    wait_for_listen(50075)

    # init hdfs
    sudo('su - hdfs -c "hadoop fs -mkdir -p /tmp"')
    sudo('su - hdfs -c "hadoop fs -chmod 1777 /tmp"')
    sudo('su - hdfs -c "hadoop fs -mkdir -p /user/hdfs"')

    # test hdfs
    sudo('su - hdfs -c "dd if=/dev/zero of=100mb.img bs=1M count=100"')
    sudo('su - hdfs -c "hadoop fs -rm -f test.img"')
    sudo('su - hdfs -c "hadoop fs -put 100mb.img test.img"')


@task
def change_to_cluster_mode():
    tpl = open('template/hdfs-site-cluster.xml').read()
    s = tpl % {'CLUSTER_NAME':'mycluster', 'NAMENODE_1':'nn1', 'NAMENODE_2':'nn2'}
    print tmp(s)

    tpl = open('template/core-site-cluster.xml').read()
    s = tpl % {'CLUSTER_NAME':'mycluster', 'NAMENODE_1':'nn1', 'NAMENODE_2':'nn2'}
    print tmp(s)
    

