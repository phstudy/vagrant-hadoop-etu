su - hdfs -c "nohup hdfs namenode &"
su - hdfs -c "nohup hdfs datanode &"


su - yarn -c "nohup yarn resourcemanager &"
su - yarn -c "nohup yarn nodemanager &"

su - zookeeper -c 'cd $HOME && sh /opt/zookeeper/bin/zkServer.sh start'
su - hbase -c "start-hbase.sh"
su - hdfs -c "nohup mapred historyserver &"

