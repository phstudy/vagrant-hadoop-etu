# create users
useradd hadoop
useradd nutn
useradd hdfs -g hadoop
useradd yarn -g hadoop
useradd hbase -g hadoop
useradd zookeeper -g hadoop

# prepare dirs
mkdir -p /opt/zkdata
chown -R zookeeper:hadoop /opt/zkdata

mv etu-hadoop /opt/etu-hadoop
chown -R hadoop:hadoop /opt/etu-hadoop

ln -s /opt/etu-hadoop/hadoop-2.2.0 /opt/hadoop
ln -s /opt/etu-hadoop/zookeeper-3.4.6 /opt/zookeeper
ln -s /opt/etu-hadoop/pig-0.12.1 /opt/pig
ln -s /opt/etu-hadoop/apache-hive-0.13.0-bin /opt/hive
