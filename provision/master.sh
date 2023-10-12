#!/usr/bin/env bash

# This script configures the master node
# and initializes the Kubernetes cluster

echo -e "\n################################"
echo "#                              #"
echo "#    Creating Master Node      #"
echo "#                              #"
echo "################################"
echo -e "\nMachine: $(hostname -s)"
set -euo pipefail

MASTER_IP=$1
POD_NETWORK=$2
SERVICE_NETWORK=$3
CALICO_VERSION=$4

mkdir -p /vagrant/generated

echo -e "\n\n---------------------------------"
echo "Initializing the Kubernetes Cluster"
echo -e "---------------------------------\n"
kubeadm init --apiserver-advertise-address=$MASTER_IP --apiserver-cert-extra-sans=$MASTER_IP --pod-network-cidr=$POD_NETWORK --service-cidr=$SERVICE_NETWORK --node-name "$(hostname -s)"

echo -e "\n\n---------------------------------"
echo "Set up kubectl configuration"
echo -e "---------------------------------\n"

# Create config for vagrant user
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config
chmod 600 /home/vagrant/.kube/config

# Create config for root user
mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
chmod 600 $HOME/.kube/config

# Copy a copy of the config into the /vagrant/generated dir
# for the future use by the user
cp /etc/kubernetes/admin.conf /vagrant/generated/config

echo -e "\n\n---------------------------------"
echo "Setting correct INTERNAL IP"
echo -e "---------------------------------\n"

sed -i "s/\(\"\)$/ --node-ip=$(ip -o -4 address show dev enp0s8 | awk '{print $4}' | cut -d/ -f1)\"/" /var/lib/kubelet/kubeadm-flags.env

systemctl daemon-reload
systemctl restart kubelet

sleep 5

echo -e "\n\n---------------------------------"
echo "Installing Calico into the cluster"
echo -e "---------------------------------\n"
kubectl  create -f https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/calico.yaml

echo -e "\n\n---------------------------------------"
echo "Generating the join script for workers"
echo -e "---------------------------------------\n"
kubeadm token create --print-join-command > /vagrant/generated/join.sh

echo -e "\n\n-------------------------------------------------"
echo "Master node $(hostname -s) configured, moving on "
echo -e "-------------------------------------------------\n"