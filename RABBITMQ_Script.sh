#!/bin/bash

# Provisioning RabbitMQ Machine
echo "Starting RabbitMQ Machine Provisioning!"

# Update OS with Latest Patches
echo "Updating system packages..."
sudo yum update -y || { echo "Failed to update system packages"; exit 1; }

# Set EPEL Repository
echo "Setting up EPEL repository..."
sudo yum install epel-release -y || { echo "Failed to install EPEL repository"; exit 1; }

# Install Dependencies
echo "Installing dependencies..."
sudo yum install wget -y || { echo "Failed to install wget"; exit 1; }

# Navigate to /tmp
echo "Navigating to /tmp..."
cd /tmp || { echo "Failed to navigate to /tmp"; exit 1; }

# Enable RabbitMQ Repository and Install RabbitMQ Server
echo "Enabling RabbitMQ repository and installing RabbitMQ server..."
sudo dnf -y install centos-release-rabbitmq-38 || { echo "Failed to enable RabbitMQ repository"; exit 1; }
sudo dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server || { echo "Failed to install RabbitMQ server"; exit 1; }

# Enable and Start RabbitMQ Server
echo "Enabling and starting RabbitMQ server..."
sudo systemctl enable --now rabbitmq-server || { echo "Failed to enable and start RabbitMQ server"; exit 1; }

# Configure RabbitMQ User Access
echo "Configuring RabbitMQ user access..."
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config' || { echo "Failed to configure RabbitMQ loopback users"; exit 1; }
sudo rabbitmqctl add_user test test || { echo "Failed to add RabbitMQ user 'test'"; exit 1; }
sudo rabbitmqctl set_user_tags test administrator || { echo "Failed to set RabbitMQ user 'test' as administrator"; exit 1; }

# Restart RabbitMQ Server to Apply Changes
echo "Restarting RabbitMQ server..."
sudo systemctl restart rabbitmq-server || { echo "Failed to restart RabbitMQ server"; exit 1; }

# Start FirewallD
echo "Starting FirewallD service..."
sudo systemctl start firewalld || { echo "Failed to start FirewallD"; exit 1; }
sudo systemctl enable firewalld || { echo "Failed to enable FirewallD"; exit 1; }


# Configure Firewall
echo "Configuring the firewall for RabbitMQ..."
sudo firewall-cmd --add-port=5672/tcp --permanent || { echo "Failed to open TCP port 5672"; exit 1; }
sudo firewall-cmd --reload || { echo "Failed to reload firewall rules"; exit 1; }

# Check RabbitMQ Server Status
echo "Checking RabbitMQ server status..."
sudo systemctl status rabbitmq-server || { echo "Failed to get RabbitMQ server status"; exit 1; }

echo "RabbitMQ provisioning completed successfully!"

