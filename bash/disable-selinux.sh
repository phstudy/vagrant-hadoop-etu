#!/usr/bin/env bash

setenforce 0
sed -i 's/SELINUX=\(enforcing\|permissive\)/SELINUX=disabled/g' /etc/selinux/config

exit 0
