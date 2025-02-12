#!/bin/bash

# Variables
NGINX_CONF="/etc/nginx/sites-available/vproapp"
NGINX_ENABLED="/etc/nginx/sites-enabled/vproapp"

# Step 1: Update and Upgrade System Packages
echo "Updating and upgrading system packages..."
sudo apt update -y && sudo apt upgrade -y || { echo "Failed to update and upgrade packages"; exit 1; }

# Step 2: Install Nginx
echo "Installing Nginx..."
sudo apt install nginx -y || { echo "Failed to install Nginx"; exit 1; }

# Step 3: Create Nginx Configuration File
echo "Creating Nginx configuration file at $NGINX_CONF..."
sudo bash -c "cat > $NGINX_CONF" <<EOF
upstream vproapp {
    server app01:8080;
}
server {
    listen 80;
    location / {
        proxy_pass http://vproapp;
    }
}
EOF

if [ $? -ne 0 ]; then
    echo "Failed to create Nginx configuration file."
    exit 1
fi
echo "Nginx configuration file created successfully."

# Step 4: Remove Default Nginx Configuration
echo "Removing default Nginx configuration..."
sudo rm -rf /etc/nginx/sites-enabled/default || { echo "Failed to remove default configuration"; exit 1; }

# Step 5: Enable New Nginx Configuration
echo "Enabling new Nginx configuration..."
sudo ln -s $NGINX_CONF $NGINX_ENABLED || { echo "Failed to enable Nginx configuration"; exit 1; }

# Step 6: Restart Nginx
echo "Restarting Nginx..."
sudo systemctl restart nginx || { echo "Failed to restart Nginx"; exit 1; }

echo "Nginx setup completed successfully!"

