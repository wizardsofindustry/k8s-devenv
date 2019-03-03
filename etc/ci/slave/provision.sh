#!/bin/sh
user=jenkins
group=jenkins
uid=500
gid=500
JENKINS_HOME=/var/lib/jenkins

# Create the local Jenkins user and ensure that the public
# key for the CI/CD server is installed to it.
mkdir -p $JENKINS_HOME \
  && chown ${uid}:${gid} $JENKINS_HOME \
  && groupadd -g ${gid} ${group} \
  && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}
sudo -u $user mkdir -p $JENKINS_HOME/.ssh\
  && chmod 700 $JENKINS_HOME/.ssh
cp /vagrant/pki/jenkins.pub $JENKINS_HOME/.ssh/authorized_keys
chown jenkins:jenkins $JENKINS_HOME/.ssh/authorized_keys
chmod 644 $JENKINS_HOME/.ssh/authorized_keys
usermod -aG docker $user
chmod 664 /var/run/docker.sock

sudo apt-get update
sudo apt-get install -y default-jdk
sudo apt-get install -y apt-transport-https
sudo apt-get install -y ca-certificates
sudo apt-get install -y curl
sudo apt-get install -y software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'
sudo apt-get update
sudo apt-get install -y docker-ce
