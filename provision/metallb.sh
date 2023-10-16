#!/usr/bin/env bash

# This script installs metallb into the cluster

set -euo pipefail

printf "\nCreating metallb namespace\n"
sudo -i -u vagrant kubectl create namespace metallb-system

echo "Applying metallb-native manifest from github"
sudo -i -u vagrant kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.11/config/manifests/metallb-native.yaml
printf "\nManifest installed, installing metallb configuration\n\n"
# Maximum number of retries
max_retries=10

# Current retry count
retry_count=0

cp /vagrant/provision/yaml/metallb.yaml /tmp/metallb.yaml
sed -i "s/<<ADDRESS_RANGE>>/$1/g" /tmp/metallb.yaml

sleep 30

while [ $retry_count -lt $max_retries ]; do
    # Run the command
    if sudo -i -u vagrant kubectl apply -f /tmp/metallb.yaml 
    then
        printf "\nMETALLB INSTALLED\n\n"
        break
    else
        # Command failed, increment retry count and wait before retrying
        retry_count=$((retry_count + 1))
        echo "Waiting for metallb to come online..."
        sleep 30  # Adjust the sleep duration as needed
    fi
done

# Check if the maximum number of retries was reached
if [ $retry_count -eq $max_retries ]; then
    echo "ERROR: METALLB INSTALLATION FAILED"
fi


