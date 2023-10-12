#!/usr/bin/env bash

# This script installs longhorn into the cluster

echo -e "\n################################"
echo "#                              #"
echo "#    Installing Longhorn       #"
echo "#                              #"
echo "################################"
echo -e "\nMachine: $(hostname -s)"
#set -euo pipefail

echo -e "\n\n---------------------------------"
echo "Installing required packages"
echo -e "---------------------------------\n"

apt update
apt install -y nfs-common open-iscsi
systemctl enable --now iscsid

echo -e "\n\n---------------------------------"
echo "Preparing Helm repository"
echo -e "---------------------------------\n"

helm repo add longhorn https://charts.longhorn.io
helm repo update

echo -e "\n\n---------------------------------"
echo "Installing Longhorn into the cluster"
echo -e "---------------------------------\n"

helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.5.1 --values /vagrant/provision/yaml/longhorn-values.yaml

while true; do
    # Get the pod statuses
    pod_statuses=$(kubectl get pods -n "longhorn-system" | grep -Eo '[0-9]/[0-9]')

    # Check if any pod has status 0/1
    if [[ $pod_statuses == *'0/1'* ]]; then
        echo "Waiting for Longhorn to come online..."
        sleep 10  # Adjust the sleep duration as needed
    else
        break
    fi
done

kubectl delete service longhorn-frontend -n longhorn-system




echo -e "\n\n---------------------------------"
echo "Longhorn installed, moving on"
echo -e "---------------------------------\n"