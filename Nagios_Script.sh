#!/bin/bash

echo "Provisioning Nagios Machine started :] !"

# Update the system
echo "Updating system packages..."
sudo yum update -y && sudo yum upgrade -y || { echo "Failed to update packages"; exit 1; }

# Install prerequisites
echo "Installing prerequisites..."
sudo yum install -y epel-release || { echo "Failed to install EPEL repository"; exit 1; }
sudo yum install -y httpd php gcc glibc glibc-common gd gd-devel make net-snmp unzip wget || { echo "Failed to install required packages"; exit 1; }

# Create Nagios User and Group
echo "Creating Nagios user and group..."
sudo useradd nagios
sudo groupadd nagios_group
sudo usermod -a -G nagios_group nagios
sudo usermod -a -G nagios_group apache

# Download and Extract Nagios Core
echo "Downloading and extracting Nagios Core..."
cd /tmp
sudo wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz || { echo "Failed to download Nagios"; exit 1; }
sudo tar -xzf nagios-4.4.6.tar.gz
cd nagios-4.4.6

# Compile and Install Nagios
echo "Compiling and installing Nagios..."
./configure --with-command-group=nagios_group || { echo "Failed to configure Nagios"; exit 1; }
make all || { echo "Failed to compile Nagios"; exit 1; }
sudo make install || { echo "Failed to install Nagios"; exit 1; }
sudo make install-init || { echo "Failed to install Nagios init script"; exit 1; }
sudo make install-config || { echo "Failed to install Nagios configuration files"; exit 1; }
sudo make install-commandmode || { echo "Failed to set Nagios command mode"; exit 1; }
sudo make install-webconf || { echo "Failed to install Nagios web configuration"; exit 1; }

# Set Nagios Admin Password
echo "Setting Nagios admin password..."
sudo htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin nagios || { echo "Failed to set Nagios admin password"; exit 1; }

# Enable and Start Services
echo "Enabling and starting services..."
sudo systemctl enable httpd || { echo "Failed to enable Apache"; exit 1; }
sudo systemctl start httpd || { echo "Failed to start Apache"; exit 1; }
sudo systemctl enable nagios || { echo "Failed to enable Nagios"; exit 1; }
sudo systemctl start nagios || { echo "Failed to start Nagios"; exit 1; }

# Configure the Firewall
echo "Configuring the firewall..."
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --permanent --add-service=http || { echo "Failed to configure HTTP service in firewall"; exit 1; }
sudo firewall-cmd --permanent --add-port=5666/tcp || { echo "Failed to configure NRPE port in firewall"; exit 1; }
sudo firewall-cmd --reload || { echo "Failed to reload firewall rules"; exit 1; }

echo "Provisioning Nagios Machine completed successfully! ;]"
