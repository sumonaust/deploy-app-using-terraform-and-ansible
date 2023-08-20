#!/bin/bash

# Apply the Kubernetes dashboard configuration
sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml

# Create the dashboard-adminuser.yaml file
cat << EOF > dashboard-adminuser.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dashboard-adminuser
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dashboard-adminuser
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: dashboard-adminuser
  namespace: kubernetes-dashboard
EOF

# Apply the dashboard-adminuser configuration
sudo kubectl apply -f dashboard-adminuser.yaml

# Get and display the token
TOKEN=$(sudo kubectl -n kubernetes-dashboard get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='dashboard-adminuser')].data.token}" | base64 --decode)
echo "Token: $TOKEN"

# Start kubectl proxy
echo "Run the following command in a new terminal to start the kubectl proxy:"
echo "sudo kubectl proxy"

# Display the dashboard URL
echo "Open the following URL in your browser to access the Kubernetes dashboard:"
echo "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"

# Reminder to open inbound port
echo "Don't forget to open the inbound port!"
