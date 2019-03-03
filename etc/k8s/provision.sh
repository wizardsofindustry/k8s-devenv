#!/bin/sh -e
# Install Docker, Rancher Kubernetes Engine (RKE) and deploy
# a local repository.
export PATH="$PATH:/opt/bin"
K8SUSER=admin-user
CERTS_DIR=/vagrant/pki
CONFIG_DIR=/vagrant/etc/k8s
OUTPUT_DIR=/vagrant
DOCKER_VERSION="17.03"


apt update && apt install -y libghc-yaml-dev
if ! command -v docker >/dev/null; then
  curl -Ss https://releases.rancher.com/install-docker/$DOCKER_VERSION.sh | sh
  usermod -aG docker ubuntu
  sleep 5
fi

# Ensure that the SSH key may be used to connect to this node,
# so that RKE can provision it.
ssh_user=root
home="$(eval echo ~$ssh_user)"
mkdir -p "$home/.ssh"
if [ ! -e "$home/.ssh/id_rsa" ]; then
  curl -Ss https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub >> "$home/.ssh/authorized_keys"
  curl -Ss https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant > "$home/.ssh/id_rsa"
  chown "$ssh_user" "$home/.ssh/id_rsa"
  chmod 400 "$home/.ssh/id_rsa"
fi

# Install Rancher Kubernetes Engine (RKE) and copy the configuration
# file so the cluster may be intialized.
if [ ! -e "/usr/local/etc/kube_config_cluster.yml" ]; then
  mkdir -p /opt/bin
  curl -LSs \
      https://github.com/rancher/rke/releases/download/v0.1.6/rke_linux-amd64 > /opt/bin/rke
  chmod +x /opt/bin/rke
  cp $CONFIG_DIR/cluster.yml /usr/local/etc/cluster.yml
  chmod 777 /usr/local/etc # TODO: Find the CORRECT permissions.
  chmod 777 /usr/local/etc/cluster.yml
  n=0
  until [ $n -ge 5 ]
  do
    rke up --config /usr/local/etc/cluster.yml && break
    n=$[$n+1]
  done
fi

# Ensure that kubectl is installed
export KUBECONFIG=/usr/local/etc/kube_config_cluster.yml
if ! command -v kubectl >/dev/null; then
  mkdir -p /usr/local/bin
  mkdir -p /home/ubuntu/.kube /root/.kube
  chmod 777 /usr/local/etc/kube_config_cluster.yml
  snap install kubectl --classic
  ln -svf /snap/bin/kubectl /usr/local/bin/kubectl
  ln -svf /usr/local/etc/kube_config_cluster.yml /home/ubuntu/.kube/config
  apt install -y jq
fi
if ! kubectl --kubeconfig /usr/local/etc/kube_config_cluster.yml \
      get pods --all-namespaces | grep dashboard; then
  kubectl create secret tls x509.tls.org.quantumframework.local\
    -n kube-system\
    --key $CERTS_DIR/key.pem\
    --cert $CERTS_DIR/crt.pem
  kubectl create secret tls x509.tls.org.quantumframework.local.k8s\
    -n kube-system\
    --key $CERTS_DIR/k8s.rsa\
    --cert $CERTS_DIR/k8s.crt
  kubectl --kubeconfig /usr/local/etc/kube_config_cluster.yml \
    create -f $CONFIG_DIR/dashboard.yml
  kubectl --kubeconfig /usr/local/etc/kube_config_cluster.yml \
    create -f $CONFIG_DIR/dashboard-admin.yml
  kubectl --kubeconfig /usr/local/etc/kube_config_cluster.yml \
    create -f $CONFIG_DIR/dashboard-ingress.yml
  kubectl --kubeconfig /usr/local/etc/kube_config_cluster.yml \
    create -f $CONFIG_DIR/user.yml
  kubectl --kubeconfig /usr/local/etc/kube_config_cluster.yml \
    create -f $CONFIG_DIR/namespaces.yml
  kubectl create namespace cicd
  kubectl create namespace cicd-ephemeral
fi
secret=$(kubectl -n kube-system get secret -n kube-system | grep $K8SUSER | awk '{print $1}')
user_token=$(kubectl get secret -n kube-system $secret -o json | jq -r '.data["token"]' | base64 -d)
ctx=`kubectl config current-context`
cluster=`kubectl config get-contexts $ctx | awk '{print $3}' | tail -n 1`
endpoint="k8s.local.quantumframework.org:8001"
kubectl get secret -n kube-system $secret -o json | jq -r '.data["ca.crt"]' | base64 -d > $OUTPUT_DIR/pki/k8s-cluster.crt
echo $user_token > $OUTPUT_DIR/token.txt

# Create a new kubectl config file for the host machine.
unset KUBECONFIG
cd /vagrant && rm -rf kubectl.yml
K8S_CTX=_quantum-local
kubectl config set-cluster $K8S_CTX \
  --embed-certs=true \
  --server=http://$endpoint \
  --certificate-authority=$OUTPUT_DIR/pki/k8s-cluster.crt
kubectl config set-credentials $K8S_CTX --token=$user_token
kubectl config set-context $K8S_CTX \
  --cluster=$K8S_CTX \
  --user=$K8S_CTX \
  --namespace=default
kubectl config use-context $K8S_CTX


# Install the kubectl-proxy service to it always runs.
if [ ! -e "/lib/systemd/system/kubectl-proxy.service" ]; then
  cp $CONFIG_DIR/kubectl-proxy.service /lib/systemd/system/
  systemctl enable kubectl-proxy
  systemctl start kubectl-proxy
fi


# Extract the client certificates from the local kubeconfig
# file, so it may be used by other nodes to connect to the
# Kubernetes cluster.
#cat /usr/local/etc/kube_config_cluster.yml |\
#  yaml2json - |\
#  jq '.users[0].user["client-key-data"]' |\
#  sed 's/^"\(.*\)"$/\1/' |\
#  base64 -d >\
#  $OUTPUT_DIR/pki/k8s-client.key
#
#cat /usr/local/etc/kube_config_cluster.yml |\
#  yaml2json - |\
#  jq '.users[0].user["client-certificate-data"]' |\
#  sed 's/^"\(.*\)"$/\1/' |\
#  base64 -d >\
#  $OUTPUT_DIR/pki/k8s-client.crt

#openssl pkcs12 -export -clcerts\
#  -inkey $OUTPUT_DIR/pki/k8s-client.key\
#  -in $OUTPUT_DIR/pki/k8s-client.crt\
#  -out $OUTPUT_DIR/pki/k8s-client.p12\
#  -password pass:quantum

# Create a Kubernetes secret that the Jenkins master
# may use to access slaves.
if [ ! -e "$CERTS_DIR/jenkins" ]; then
  ssh-keygen -t rsa -f $CERTS_DIR/jenkins -q -P ""
  kubectl create secret generic -n cicd jenkins.secrets.ssh-slave\
    --from-file=privateKey=$CERTS_DIR/jenkins\
    --from-literal=username=jenkins
  kubectl label secret -n cicd jenkins.secrets.ssh-slave\
    jenkins.io/credentials-type=basicSSHUserPrivateKey
  kubectl annotate secret -n cicd jenkins.secrets.ssh-slave\
    jenkins.io/credentials-description="Private key for SSH Slaves"
fi


# Configure the cluster for local usage.
kubectl apply -f /vagrant/etc/ci/jenkins/k8s.yml
