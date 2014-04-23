#!/bin/bash

user=nutn

## clean HDFS
su -s /bin/bash $user -c "hadoop fs -rm test.img"


## clean pig
su -s /bin/bash $user -c "hadoop fs -rm -r /tmp/pig_output"

## clean hive
cat > /tmp/clean_hive_test.hql << EOF
DROP TABLE baseball.master;
DROP DATABASE baseball;
quit;
EOF
su -s /bin/bash $user -c "hive -f /tmp/clean_hive_test.hql"

exit 0