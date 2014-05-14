#!/usr/bin/env bash

yum -y install wget

wget http://public-repo-1.hortonworks.com/ambari/centos6/1.x/updates/1.5.1/ambari.repo
mv ambari.repo /etc/yum.repos.d
yum repolist
yum -y install ambari-server
ambari-server setup
ambari-server start

echo "please visit http://${HOSTNAME}:8080"

exit 0
