#!/bin/sh
apt update && apt install -y mysql-client-core-5.7
if [ ! -e "/lib/systemd/system/mysql-server.service" ]; then
  cp $CONFIG_DIR/mysql-server.service /lib/systemd/system/
  systemctl enable mysql-server
  systemctl start mysql-server
fi

