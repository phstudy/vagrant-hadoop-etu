#!/bin/bash

## datasets
#excite_small_dataset_url=http://www.hadoop.tw/excite-small.log
#lahman2012_csv_dataset_url=http://seanlahman.com/files/database/lahman2012-csv.zip
excite_small_dataset_url=http://hadoop-etu.s3.amazonaws.com/dataset/excite-small.log
lahman2012_csv_dataset_url=http://hadoop-etu.s3.amazonaws.com/dataset/lahman2012-csv.zip

## non-root user
user=nutn

cd /home/$user

## run HDFS test case
dd if=/dev/zero of=/tmp/100mb.img bs=1M count=100
su -s /bin/bash $user -c "hadoop fs -put /tmp/100mb.img test.img"
su -s /bin/bash root -c "hadoop fs -put /tmp/100mb.img test.img"
su -s /bin/bash hdfs -c "hadoop fs -put /tmp/100mb.img test.img"

## run mapreduce for function test
su -s /bin/bash $user -c "hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar pi 2 2"

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
su -s /bin/bash $user -c "hbase shell /tmp/hbase_test"

## run pig test case
wget $excite_small_dataset_url -O /tmp/excite-small.log
su - $user -s /bin/bash -c "hadoop fs -put /tmp/excite-small.log /tmp/excite-small.log"
cat > /tmp/pig_test.pig << EOF
log = LOAD '/tmp/excite-small.log' AS (user, timestamp, query);
grpd = GROUP log BY user;  
cntd = FOREACH grpd GENERATE group, COUNT(log) AS cnt;
fltrd = FILTER cntd BY cnt > 50;      
srtd = ORDER fltrd BY cnt;
STORE srtd INTO '/tmp/pig_output';
EOF
su -s /bin/bash $user -c "pig -f /tmp/pig_test.pig"

## run hive test case
wget $lahman2012_csv_dataset_url -O /tmp/lahman2012-csv.zip
( cd /tmp; unzip -o /tmp/lahman2012-csv.zip )
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
su -s /bin/bash $user -c "hive -f /tmp/hive_test.hql"

if [ -f /usr/local/bin/send_my_score ]; then
  echo "send my score"
  /usr/local/bin/send_my_score
fi

exit 0
