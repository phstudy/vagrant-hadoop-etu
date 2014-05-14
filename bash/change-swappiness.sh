#!/usr/bin/env bash

TARGET_KEY=vm.swappiness
REPLACEMENT_VALUE=0
CONFIG_FILE=/etc/sysctl.conf

echo "set vm.swappiness from $(cat /proc/sys/vm/swappiness) to 0 into $CONFIG_FILE"

# change swappiness runtime
sysctl -w vm.swappiness=0

# change swappiness in conf
sed -c -i "s/\($TARGET_KEY *= *\).*/\1$REPLACEMENT_VALUE/" $CONFIG_FILE
map="vm.swappiness"
grep "$map" $CONFIG_FILE > /dev/null  || echo "$map = 0" >> $CONFIG_FILE

exit 0