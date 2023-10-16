#!/usr/bin/env bash

# This script initializes all of the provisioned machines
# to make sure they are ready to be part of a Kubernetes
# cluster.

set -euo pipefail

echo -e "\n################################"
echo "#                              #"
echo "#    Initial Configuration     #"
echo "#                              #"
echo "################################"
echo -e "\nMachine: $(hostname -s)"

# Handle Arguments

DNS_SERVERS=$1
K8S_VERSION=$2

echo -e "\n\n---------------------------------"
echo "Setting DNS Configuration"
echo -e "---------------------------------\n"

# MAke the resolved.conf.d dir if required
# and add the DNS configuration into resolved
if [ ! -d /etc/systemd/resolved.conf.d ]; then
	sudo mkdir /etc/systemd/resolved.conf.d/
fi
cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/dns_servers.conf
[Resolve]
DNS=${DNS_SERVERS}
EOF

# Restart resolved to ensure DNS changes take effect
sudo systemctl restart systemd-resolved


echo -e "\n\n---------------------------------"
echo "Disabling Swap"
echo -e "---------------------------------\n"

# Turn off any existing swap, and create a crontab to do it on reboot
# as well.
sudo swapoff -a
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true


echo -e "\n\n---------------------------------"
echo "Update and Upgrade Packages"
echo -e "---------------------------------\n"

sudo apt update -y
sudo apt upgrade -y


echo -e "\n\n---------------------------------"
echo "Installing Required Packages"
echo -e "---------------------------------\n"

apt install -y ca-certificates curl gnupg lsb-release jq


echo -e "\n\n---------------------------------------"
echo "Configuring Kernel modules and Paramaters"
echo -e "---------------------------------------\n"

# Add the overlay and br_netfilter modules on boot
cat <<EOF | sudo tee /etc/modules-load.d/cri.conf
overlay
br_netfilter
EOF

# enable the modules now
modprobe overlay
modprobe br_netfilter

# Kuberentes sysctl requirements
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system


echo -e "\n\n---------------------------------------"
echo "Installing and Configuring containerd"
echo -e "---------------------------------------\n"

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list
apt update -qq  
apt install -qq -y containerd.io  
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl restart containerd 
systemctl enable containerd


echo -e "\n\n---------------------------------"
echo "Installing Kuberenetes Packages"
echo -e "---------------------------------\n"

sudo apt-get update -y
if [ -z "$K8S_VERSION" ] || [[ "$K8S_VERSION" == "latest" ]]; then
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
  apt update
  apt-get install -y kubelet kubectl kubeadm
else
  VER=$(echo $K8S_VERSION | cut -d'.' -f1,2)
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v$VER/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$VER/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  apt update
  INSTALL_VERSION=$(apt list -a kubeadm | grep -E "kubeadm/unknown $K8S_VERSION" | head -n 1 | awk '{print $2}')
  # Install a specific version of kubernetes
  apt-get install -y kubelet="$INSTALL_VERSION" kubectl="$INSTALL_VERSION" kubeadm="$INSTALL_VERSION"
fi

echo -e "\n\n---------------------------------"
echo "Installing Helm"
echo -e "---------------------------------\n"

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo -e "\n\n-------------------------------------------------"
echo "Initialization for $(hostname -s) complete, moving on "
echo -e "-------------------------------------------------\n"