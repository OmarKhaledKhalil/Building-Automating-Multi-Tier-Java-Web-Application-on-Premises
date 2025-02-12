#!/bin/bash

# Variables
DB_ROOT_PASSWORD="Omar123"
DB_USER="admin"
DB_USER_PASSWORD="Omar123"
DB_NAME="accounts"
REPO_URL="https://github.com/hkhcoder/vprofile-project.git"
DB_BACKUP_PATH="src/main/resources/db_backup.sql"

echo "Starting MariaDB provisioning..."

# Step 1: Update and Upgrade System Packages
echo "Updating system packages..."
sudo yum update -y || { echo "Failed to update system packages"; exit 1; }

# Step 2: Install EPEL Repository
echo "Installing EPEL repository..."
sudo yum install epel-release -y || { echo "Failed to install EPEL repository"; exit 1; }

# Step 3: Install MariaDB and Git
echo "Installing MariaDB and Git..."
sudo yum install git mariadb-server -y || { echo "Failed to install MariaDB or Git"; exit 1; }

# Step 4: Start and Enable MariaDB Service
echo "Starting and enabling MariaDB service..."
sudo systemctl start mariadb || { echo "Failed to start MariaDB"; exit 1; }
sudo systemctl enable mariadb || { echo "Failed to enable MariaDB"; exit 1; }

# Step 5: Secure MariaDB Installation
echo "Securing MariaDB installation..."
sudo mysql_secure_installation <<EOF

Y
$DB_ROOT_PASSWORD
$DB_ROOT_PASSWORD
Y
n
Y
Y
EOF

# Step 6: Set Up Database and User
echo "Creating database and user..."
sudo mysql -u root -p"$DB_ROOT_PASSWORD" <<EOF
CREATE DATABASE $DB_NAME;
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_USER_PASSWORD';
FLUSH PRIVILEGES;
EOF

# Step 7: Clone Source Code and Initialize Database
echo "Cloning repository and initializing database..."
if [ ! -d "vprofile-project" ]; then
  git clone -b main $REPO_URL || { echo "Failed to clone repository"; exit 1; }
else
  echo "Repository already exists. Skipping clone."
fi

cd vprofile-project || { echo "Failed to navigate to project directory"; exit 1; }

if [ -f "$DB_BACKUP_PATH" ]; then
  sudo mysql -u root -p"$DB_ROOT_PASSWORD" $DB_NAME < "$DB_BACKUP_PATH" || { echo "Failed to restore database from backup"; exit 1; }
else
  echo "Database backup file not found: $DB_BACKUP_PATH"
  exit 1
fi

# Verify the database
sudo mysql -u root -p"$DB_ROOT_PASSWORD" -e "USE $DB_NAME; SHOW TABLES;"

# Step 8: Restart MariaDB
echo "Restarting MariaDB service..."
sudo systemctl restart mariadb || { echo "Failed to restart MariaDB"; exit 1; }

# Step 9: Configure Firewall
echo "Configuring firewall..."
sudo systemctl start firewalld || { echo "Failed to start firewalld"; exit 1; }
sudo systemctl enable firewalld || { echo "Failed to enable firewalld"; exit 1; }
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent || { echo "Failed to open port 3306"; exit 1; }
sudo firewall-cmd --reload || { echo "Failed to reload firewall rules"; exit 1; }

echo "MariaDB provisioning completed successfully!"

