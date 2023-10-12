#!/usr/bin/env bash

# This script installs metallb into the cluster

echo -e "\n################################"
echo "#                              #"
echo "#    Installing metallb        #"
echo "#                              #"
echo "################################"
echo -e "\nMachine: $(hostname -s)"
set -euo pipefail


echo -e "\n\n---------------------------------"
echo "Creating metallb-system namespace"
echo -e "---------------------------------\n"

sudo -i -u vagrant kubectl create namespace metallb-system


echo -e "\n\n---------------------------------"
echo "Applying metallb-native manifest from github"
echo -e "---------------------------------\n"

sudo -i -u vagrant kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml >/dev/null 2>&1


echo -e "\n\n---------------------------------"
echo "Applying metallb configuration"
echo -e "---------------------------------\n"

# Maximum number of retries
max_retries=10

# Current retry count
retry_count=0

while [ $retry_count -lt $max_retries ]; do
    # Run the command
    if sudo -i -u vagrant kubectl apply -f /vagrant/provision/yaml/metallb.yaml  >/dev/null 2>&1; then
        echo -e "\n\n---------------------------------"
        echo "Metallb installed, moving on"
        echo -e "---------------------------------\n"
        break
    else
        # Command failed, increment retry count and wait before retrying
        retry_count=$((retry_count + 1))
        echo "Waiting for metallb to come online..."
        sleep 15  # Adjust the sleep duration as needed
    fi
done

# Check if the maximum number of retries was reached
if [ $retry_count -eq $max_retries ]; then
    echo -e "\n\n##############################"
    echo "METALLB INSTALLATION FAILED"
    echo -e "##############################\n"
fi


