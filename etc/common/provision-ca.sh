#!/bin/sh
DOCKER_CERTS_DIR=/etc/docker/certs.d/docker.local.quantumframework.org
apt update && apt install -y ca-certificates
cp $PKI_DIR/crt.pem /usr/share/ca-certificates
dpkg-reconfigure -f noninteractive ca-certificates
if [ ! -d "$DOCKER_CERTS_DIR" ]; then
  mkdir -p $DOCKER_CERTS_DIR
  cp $PKI_DIR/crt.pem $DOCKER_CERTS_DIR/ca.crt
fi
