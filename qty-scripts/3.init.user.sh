function init_user {
cat >> $1 << EOF
export HADOOP_HOME=/opt/hadoop
export HADOOP_MAPRED_HOME=/opt/hadoop
export HADOOP_COMMON_HOME=/opt/hadoop
export HADOOP_HDFS_HOME=/opt/hadoop
export HADOOP_YARN_HOME=/opt/hadoop
export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
export JAVA_HOME=/usr/java/jdk1.7.0_45

export HBASE_HOME=/opt/etu-hadoop/hbase-0.98.1-hadoop2
export HBASE_LOG_DIR=\$HBASE_HOME/logs

export PATH=\$PATH:\$JAVA_HOME/bin:\$HADOOP_HOME/bin:\$HBASE_HOME/bin:/opt/hive/bin:/opt/pig/bin

EOF
}

init_user /root/.bashrc
init_user /home/hadoop/.bashrc
init_user /home/hdfs/.bashrc
init_user /home/yarn/.bashrc
init_user /home/zookeeper/.bashrc
init_user /home/hbase/.bashrc
init_user /home/nutn/.bashrc

rsync -av hcfg/ /opt/etu-hadoop/hbase-0.98.1-hadoop2/conf
rsync -av hbase_ssh_files/ /home/hbase/.ssh
chown -R hbase:hadoop /home/hbase/.ssh
chmod -R 600 /home/hbase/.ssh/*
chmod 700 /home/hbase/.ssh

su - hdfs -c "hdfs namenode -format"
