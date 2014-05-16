from fabric.api import *
from fabric.utils import *
from fabric.contrib.files import *
from server_util import *

env.user = 'ec2-user'
env.roledefs = {
    'nn1':['ec2-54-254-250-58.ap-southeast-1.compute.amazonaws.com'],
    'nn2':['ec2-54-255-173-46.ap-southeast-1.compute.amazonaws.com']
}

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
    sudo('yum install -y telnet wget')
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
            puts('wait for port %d' % port)
            with settings(warn_only=True):
                count = run('v=$(netstat -an | grep LISTEN | grep -c :%d) ; echo $v' % port)
            if count != 0:
                break
            time.sleep(10)

    # wait namenode web-ui, rpc
    wait_for_listen(50070)
    wait_for_listen(8020)

    # wait datanode ports
    wait_for_listen(50010)
    wait_for_listen(50020)
    wait_for_listen(50075)

    # test hdfs
    puts('test hdfs put-operation')
    sudo('su - hdfs -c "dd if=/dev/zero of=100mb.img bs=1M count=100"')
    sudo('su - hdfs -c "hadoop fs -rm -f test.img"')
    sudo('su - hdfs -c "hadoop fs -put 100mb.img test.img"')

        
    

