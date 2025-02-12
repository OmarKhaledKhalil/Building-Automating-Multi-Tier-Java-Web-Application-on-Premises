#!/bin/bash

# Provisioning the MemCache Machine
echo "Starting MemCache Machine Provision!"

# Update and Upgrade System Packages
echo "Updating system packages..."
sudo yum update -y && sudo yum upgrade -y || { echo "Failed to update packages"; exit 1; }

# Install EPEL (Extra Packages for Enterprise Linux)
echo "Installing EPEL repository..."
sudo dnf install epel-release -y || { echo "Failed to install EPEL"; exit 1; }

# Install, Start & Enable Memcached
echo "Installing and configuring Memcached..."
sudo dnf install memcached -y || { echo "Failed to install Memcached"; exit 1; }
sudo systemctl start memcached || { echo "Failed to start Memcached"; exit 1; }
sudo systemctl enable memcached || { echo "Failed to enable Memcached"; exit 1; } 

# Check Memcached Status
sudo systemctl status memcached || { echo "Memcached service is not running properly"; exit 1; }

# Allow External Connections to Memcached
if [ -f /etc/sysconfig/memcached ]; then
  echo "Configuring Memcached to allow external connections..."
  sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
  sudo systemctl restart memcached || { echo "Failed to restart Memcached after config"; exit 1; }
else
  echo "Memcached configuration file not found!"
  exit 1
fi

echo "Starting FirewallD service..."
sudo systemctl start firewalld || { echo "Failed to start FirewallD"; exit 1; }
sudo systemctl enable firewalld || { echo "Failed to enable FirewallD"; exit 1; }

# Configuring Firewall
echo "Configuring the firewall for Memcached..."
sudo firewall-cmd --add-port=11211/tcp --permanent || { echo "Failed to open TCP port 11211"; exit 1; }
sudo firewall-cmd --add-port=11111/udp --permanent || { echo "Failed to open UDP port 11111"; exit 1; }
sudo firewall-cmd --reload || { echo "Failed to reload firewall rules"; exit 1; }

echo "Memcached provisioning completed successfully!"

