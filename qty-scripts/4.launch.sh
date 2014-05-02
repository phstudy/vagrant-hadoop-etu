su - hdfs -c "nohup hdfs namenode &"
su - hdfs -c "nohup hdfs datanode &"

su - hdfs -c "hadoop fs -mkdir -p /user/hdfs"
su - hdfs -c "hadoop fs -mkdir -p /hbase"
su - hdfs -c "hadoop fs -chown hbase /hbase"
su - hdfs -c "hadoop fs -mkdir -p /tmp"
su - hdfs -c "hadoop fs -chmod 1777 /tmp"
su - hdfs -c "hadoop fs -mkdir -p /user/nutn"
su - hdfs -c "hadoop fs -chown nutn /user/nutn"
su - hdfs -c "hadoop fs -mkdir -p /user/hive"
su - hdfs -c "hadoop fs -chown hive /user/hive"

su - yarn -c "nohup yarn resourcemanager &"
su - yarn -c "nohup yarn nodemanager &"

su - zookeeper -c 'cd $HOME && sh /opt/zookeeper/bin/zkServer.sh start'
su - hbase -c "start-hbase.sh"
su - hdfs -c "nohup mapred historyserver &"
