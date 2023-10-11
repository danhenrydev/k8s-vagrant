#!/bin/bash

echo "################################"
echo "#                              #"
echo "#   Initializing Worker Node   #"
echo "#                              #"
echo "################################"


# bash /vagrant/generated/join.sh


eval "$(</vagrant/generated/join.sh) --node-name $(hostname -s)"

cp /vagrant/generated/config /etc/kubernetes/admin.conf

sudo -u vagrant mkdir /home/vagrant/.kube
cp /vagrant/generated/config /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
