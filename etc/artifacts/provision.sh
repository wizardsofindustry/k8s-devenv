#!/bin/sh
if [ ! -e "/lib/systemd/system/docker-registry.service" ]; then
  cp $CONFIG_DIR/docker-registry.service /lib/systemd/system/
  systemctl enable docker-registry
  systemctl start docker-registry
fi
