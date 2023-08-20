#!/bin/bash

# Update package lists and install required dependencies
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

# Add Google's Kubernetes repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

# Update package lists again and install kubelet, kubeadm, and kubectl
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-get install -y nginx certbot python3-certbot-nginx
sudo apt-get install -y jq
sudo apt-get install -y python-pip
pip install flask

# Mark packages to hold their version
sudo apt-mark hold kubelet kubeadm kubectl

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

# Enable net.bridge.bridge-nf-call-iptables
sudo modprobe br_netfilter
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Enable net.ipv4.ip_forward
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Initialize the cluster using kubeadm (Change the CIDR if required)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Configure kubectl for the non-root user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Flannel for the pod network (you can also use other CNI plugins)
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "Kubernetes cluster initialized successfully!"
