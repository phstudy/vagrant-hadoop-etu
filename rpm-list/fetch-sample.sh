#!/bin/bash

wget -i iso_update.list -P /opt/
rpm -Uvh --replacepkgs /opt/*.rpm

exit 0
