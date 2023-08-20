#!/bin/bash

# Replace the line below with the 'kubeadm join' command that you copied from the master node
JOIN_COMMAND="kubeadm join 172.31.39.222:6443 --token wgmmsu.w31yr2xtpq1045kz --discovery-token-ca-cert-hash sha256:899a02cc4b1387392e4e2a24fb12d4525386550f3ab84f09cac191f1182ea986"

# Update package lists and install required dependencies
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

# Add Google's Kubernetes repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

# Update package lists again and install kubelet, kubeadm, and kubectl
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# Mark packages to hold their version
sudo apt-mark hold kubelet kubeadm kubectl

# Enable net.bridge.bridge-nf-call-iptables
sudo modprobe br_netfilter
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Enable net.ipv4.ip_forward
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Install and configure containerd
sudo apt-get update && sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Configure the kubelet to use containerd
sudo mkdir -p /etc/default/kubelet
echo "KUBELET_EXTRA_ARGS=--container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --runtime-request-timeout=2m" | sudo tee /etc/default/kubelet

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet


# Join the worker node to the cluster
#sudo $JOIN_COMMAND

echo "Worker node joined the Kubernetes cluster successfully!"
