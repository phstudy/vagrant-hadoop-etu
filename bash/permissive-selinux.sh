#!/usr/bin/env bash

sed -i 's/SELINUX=\(disabled\|enforcing\)/SELINUX=permissive/g' /etc/selinux/config

exit 0
