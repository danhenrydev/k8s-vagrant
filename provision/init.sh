#!/bin/bash

echo "################################"
echo "#                              #"
echo "#    Initial Configuration     #"
echo "#                              #"
echo "################################"

set -euxo pipefail

# Handle Arguments

DNS_SERVERS=$1
K8S_VERSION=$2

echo "--- Setting DNS Configuration ---"

# DNS Setting
if [ ! -d /etc/systemd/resolved.conf.d ]; then
	sudo mkdir /etc/systemd/resolved.conf.d/
fi
cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/dns_servers.conf
[Resolve]
DNS=${DNS_SERVERS}
EOF

sudo systemctl restart systemd-resolved


echo "--- Disabling Swap ---"

sudo swapoff -a
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true


echo "--- Updating and Upgrading Packages ---"
sudo apt update -y
sudo apt upgrade -y

echo "--- Installing Required Packages ---"
apt install -y ca-certificates curl gnupg lsb-release jq



echo "--- Configuring Kernel Modules and Parameters ---"

cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system


echo "--- Installing Containerd  ---"

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


echo "--- Installing Kubernetes Packages  ---"

sudo apt-get update -y
if [ -z "$K8S_VERSION" ] || [[ "$K8S_VERSION" == "latest" ]]; then
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
  echo "K8S_VERSION is empty or set to 'latest'."
  sudo apt-get install -y kubelet kubectl kubeadm
else
  VER=$(echo $K8S_VERSION | cut -d'.' -f1,2)
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v$VER/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$VER/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  apt update
  INSTALL_VERSION=$(apt list -a kubeadm | grep -E "kubeadm/unknown $K8S_VERSION" | head -n 1 | awk '{print $2}')
  # Install a specific version of kubernetes
  sudo apt-get install -y kubelet="$INSTALL_VERSION" kubectl="$INSTALL_VERSION" kubeadm="$INSTALL_VERSION"
fi
