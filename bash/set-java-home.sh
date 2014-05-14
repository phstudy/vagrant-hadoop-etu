#!/usr/bin/env bash

profile='/root/.bash_profile'
java_home='export JAVA_HOME=/usr/java/jdk1.7.0_55'
java_home_bin='export PATH=$PATH:$JAVA_HOME/bin'

echo "set $java_home into ~/.bash_profile"
grep "$java_home" $profile > /dev/null  || echo "$java_home" >> $profile

echo "set $java_home_bin into ~/.bash_profile"
grep "$java_home_bin" $profile > /dev/null || echo "$java_home_bin" >> $profile

source $profile

exit 0