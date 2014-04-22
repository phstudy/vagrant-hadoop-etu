#!/bin/bash

## datasets
#excite_small_dataset_url=http://www.hadoop.tw/excite-small.log
#lahman2012_csv_dataset_url=http://seanlahman.com/files/database/lahman2012-csv.zip
excite_small_dataset_url=http://hadoop-etu.s3.amazonaws.com/dataset/excite-small.log
lahman2012_csv_dataset_url=http://seanlahman.com/files/database/lahman2012-csv.zip


## update repository (may not required.)
# yum update

## install wget
#yum install -y wget

## add bigtop repo
#wget -O /etc/yum.repos.d/bigtop.repo http://archive.apache.org/dist/bigtop/stable/repos/centos6/bigtop.repo

## install hadoop related packages
#yum install -y java-1.7.0-openjdk vim bigtop-utils hadoop-conf-pseudo w3m hive pig hbase hive-hbase hbase-master hbase-regionserver hbase-rest hbase-thrift zookeeper unzip

## download hadoop packages from s3
cd /opt && { curl -O "http://hadoop-etu.s3.amazonaws.com/iso_hadoop/{wget-1.12-1.11.el6_5.x86_64.rpm,make-3.81-20.el6.x86_64.rpm,openssl-1.0.1e-16.el6_5.7.x86_64.rpm}" ; cd -; }
rpm -Uvh --replacepkgs /opt/make-3.81-20.el6.x86_64.rpm
rpm -Uvh --replacepkgs /opt/openssl-1.0.1e-16.el6_5.7.x86_64.rpm
rpm -Uvh --replacepkgs /opt/wget-1.12-1.11.el6_5.x86_64.rpm

wget http://hadoop-etu.s3.amazonaws.com/iso_hadoop.list -P /opt
wget -i /opt/iso_hadoop.list -P /opt
rpm -Uvh --replacepkgs /opt/*.rpm

## format NameNode
/etc/init.d/hadoop-hdfs-namenode init

## enable HBase with ZooKeeper
cp /etc/hbase/conf/hbase-site.xml /etc/hbase/conf/hbase-site.xml.rpm
cat > /etc/hbase/conf/hbase-site.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
      <name>hbase.rootdir</name>
      <value>hdfs://localhost:8020/hbase</value>
  </property>
  <property>
      <name>hbase.tmp.dir</name>
      <value>/var/hbase</value>
  </property>
  <property>
      <name>hbase.cluster.distributed</name>
      <value>true</value>
  </property>
</configuration>
EOF

## start HDFS
for i in hadoop-hdfs-namenode hadoop-hdfs-datanode ; do sudo service $i start ; done

## initialize HDFS
sudo /usr/lib/hadoop/libexec/init-hdfs.sh

## start ZooKeeper
mkdir -p /var/run/zookeeper && sudo chown zookeeper:zookeeper /var/run/zookeeper
su -s /bin/bash zookeeper -c "zookeeper-server-initialize"
su -s /bin/bash zookeeper -c "zookeeper-server start"

## start YARN and HBase
for i in hadoop-yarn-resourcemanager hadoop-yarn-nodemanager hadoop-mapreduce-historyserver hbase-master hbase-regionserver ; do sudo service $i start ; done

## Fix YARN staging folder permission issues
# ERROR security.UserGroupInformation: PriviledgedActionException as:root (auth:SIMPLE) 
#  cause:org.apache.hadoop.security.AccessControlException: Permission denied: 
#  user=root, access=EXECUTE, inode="/tmp/hadoop-yarn/staging":mapred:mapred:drwxrwx---
su - hdfs -s /bin/bash -c "hadoop fs -chmod 777 /tmp/hadoop-yarn/staging"

## run HDFS test case
dd if=/dev/zero of=100mb.img bs=1M count=100
hadoop fs -put 100mb.img test.img

## run mapreduce for function test
su - hdfs hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar pi 2 2

## run hbase test case
cat > /tmp/hbase_test << EOF
create 't1','f1'
put 't1','r1','f1','v1'
put 't1','r1','f1','v2'
put 't1','r1','f1:c1','v2'
put 't1','r1','f1:c2','v3'
scan 't1'
exit
EOF
hbase shell /tmp/hbase_test

## run pig test case
wget $excite_small_dataset_url -O /tmp/excite-small.log
hadoop fs -put /tmp/excite-small.log /tmp/excite-small.log
cat > /tmp/pig_test.pig << EOF
log = LOAD '/tmp/excite-small.log' AS (user, timestamp, query);
grpd = GROUP log BY user;  
cntd = FOREACH grpd GENERATE group, COUNT(log) AS cnt;
fltrd = FILTER cntd BY cnt > 50;      
srtd = ORDER fltrd BY cnt;
STORE srtd INTO '/tmp/pig_output';
EOF
su - hdfs pig /tmp/pig_test.pig

## run hive test case
wget $lahman2012_csv_dataset_url -O /tmp/lahman2012-csv.zip
( cd /tmp; unzip /tmp/lahman2012-csv.zip )
cat > /tmp/hive_test.hql << EOF
create database baseball;
create table baseball.master 
( lahmanID INT, playerID STRING, managerID INT, hofID STRING,  
  birthYear INT, birthMonth INT, birthDay INT, birthCountry STRING,  
  birthState STRING, birthCity STRING, deathYear INT, deathMonth INT, 
  deathDay INT, deathCountry STRING, deathState STRING, deathCity STRING, 
  nameFirst STRING, nameLast STRING, nameNote STRING, nameGiven STRING, 
  nameNick STRING, weight INT, height INT, bats STRING, throws STRING, 
  debut STRING, finalGame STRING, college STRING, lahman40ID STRING, 
  lahman45ID STRING, retroID STRING, holtzID STRING, bbrefID STRING ) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' ;
LOAD DATA LOCAL INPATH "/tmp/Master.csv" OVERWRITE INTO TABLE baseball.master;
select * from baseball.master LIMIT 10;
quit;
EOF
hive -f /tmp/hive_test.hql

exit 0