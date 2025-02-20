#!/bin/bash

echo "🚀 Starting AWX Installation on Ubuntu..."

# Step 1: Update System & Install Dependencies
echo "🔄 Updating system & installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y git make python3 python3-pip nodejs gettext docker docker-compose

# Start & Enable Docker
echo "🛠️ Starting & enabling Docker..."
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker

# Step 2: Install Minikube
echo "🌐 Installing Minikube..."
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

# Start Minikube Cluster
echo "🚀 Starting Minikube cluster..."
minikube start --cpus 4 --memory 8g --vm-driver=docker --addons=ingress

# Verify Minikube Status
echo "✅ Checking Minikube status..."
minikube status
kubectl get nodes

# Step 3: Deploy AWX Operator
echo "📥 Cloning AWX Operator repository..."
git clone https://github.com/ansible/awx-operator.git
cd awx-operator
git fetch --tags
latest_version=$(git tag | sort -V | tail -n1)
git checkout "$latest_version"

# Deploy AWX Operator
echo "📦 Deploying AWX Operator..."
kubectl create namespace ansible-awx
export NAMESPACE=ansible-awx
make deploy

# Wait for AWX Operator to be ready
echo "⏳ Waiting for AWX Operator to be ready..."
sleep 60
kubectl get pods -n ansible-awx

# Step 4: Deploy AWX Application
echo "📝 Creating AWX deployment file..."
cp awx-demo.yml awx-deployment.yml
cat <<EOF > awx-deployment.yml
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx-instance
spec:
  service_type: nodeport
EOF

# Deploy AWX
echo "🚀 Deploying AWX..."
kubectl create -f awx-deployment.yml -n ansible-awx

# Wait for AWX to be ready
echo "⏳ Waiting for AWX to be deployed..."
sleep 120
kubectl get pods -n ansible-awx

# Step 5: Expose AWX Web UI
echo "🌐 Exposing AWX web interface..."
minikube service awx-instance-service --url -n ansible-awx

# Step 6: Retrieve Admin Password
echo "🔑 Retrieving AWX admin password..."
admin_password=$(kubectl get secret awx-instance-admin-password -o jsonpath="{.data.password}" -n ansible-awx | base64 --decode)
echo "AWX Admin Password: $admin_password"

echo "🎉 AWX Installation Complete!"
echo "Access AWX Web UI at: $(minikube service awx-instance-service --url -n ansible-awx)"
echo "Login with Username: admin and Password: $admin_password"
