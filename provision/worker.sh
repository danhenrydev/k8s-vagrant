#!/usr/bin/env bash

# This script initializes each of the worker
# nodes and joins them to the cluster.

echo -e "\n################################"
echo "#                              #"
echo "#    Creating Worker Node      #"
echo "#                              #"
echo "################################"
echo -e "\nMachine: $(hostname -s)"
set -euo pipefail


# bash /vagrant/generated/join.sh

echo -e "\n\n---------------------------------"
echo "Joining $(hostname -s) to the Kubernetes cluster"
echo -e "---------------------------------\n"
eval "$(</vagrant/generated/join.sh) --node-name $(hostname -s)"

echo -e "\n\n---------------------------------"
echo "Preparing kubectl configuration"
echo -e "---------------------------------\n"
cp /vagrant/generated/config /etc/kubernetes/admin.conf

sudo -u vagrant mkdir /home/vagrant/.kube
cp /vagrant/generated/config /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo -e "\n\n-------------------------------------------------"
echo "Worker node $(hostname -s) configured, moving on "
echo -e "-------------------------------------------------\n"

kubectl get nodes
