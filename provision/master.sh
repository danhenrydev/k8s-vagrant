#!/bin/bash

echo "################################"
echo "#                              #"
echo "#   Initializing Master Node   #"
echo "#                              #"
echo "################################"

set -euxo pipefail

MASTER_IP=$1
POD_NETWORK=$2
SERVICE_NETWORK=$3
CALICO_VERSION=$4

mkdir -p /vagrant/generated

echo "--- Initializing the cluster ---"
sudo kubeadm init --apiserver-advertise-address=$MASTER_IP --apiserver-cert-extra-sans=$MASTER_IP --pod-network-cidr=$POD_NETWORK --service-cidr=$SERVICE_NETWORK --node-name "$(hostname -s)"

echo "--- Creating kubeconfig ---"
mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config

mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

cp /etc/kubernetes/admin.conf /vagrant/generated/config

sleep 5

echo "--- Installing calico ---"
kubectl  create -f https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/calico.yaml

echo "--- Create join script ---"
kubeadm token create --print-join-command > /vagrant/generated/join.sh