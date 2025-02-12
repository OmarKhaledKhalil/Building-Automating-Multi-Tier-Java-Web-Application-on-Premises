#!/bin/bash

echo "Application Machine Provision Starts!"

# Update OS with Latest Patches
echo "Updating system packages..."
sudo yum update -y || { echo "Failed to update system packages"; exit 1; }

# Set EPEL Repository
echo "Setting up EPEL repository..."
sudo yum install epel-release -y || { echo "Failed to install EPEL repository"; exit 1; }

# Removing Java Versions and Install Java 11
echo "Removing existing Java versions..."
sudo dnf remove -y java-*-openjdk java-*-openjdk-devel || { echo "Failed to remove existing Java versions"; exit 1; }
sudo dnf autoremove -y || { echo "Failed to perform autoremove"; exit 1; }
echo "Installing Java 11"
sudo dnf -y install java-11-openjdk java-11-openjdk-devel || { echo "Failed to Install Java 11"; exit 1; }

# Install Maven to build the code
echo "Install Maven"
sudo dnf install git maven wget -y


# Install Tomcat
echo "Install Tomcat"
cd /tmp/
sudo wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz
sudo tar xzvf apache-tomcat-9.0.75.tar.gz

# Create a user for Tomcat and set for it the home directory and shell
sudo useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat

# Copy the data to Tomcat home directory
sudo cp -r /tmp/apache-tomcat-9.0.75/* /usr/local/tomcat/

# Make tomcat user owner of tomcat home dir
sudo chown -R tomcat.tomcat /usr/local/tomcat


# Provisioning Tomcat

echo "Starting Tomcat provisioning..."

# Step 1: Create Tomcat Systemd Service File
echo "Creating Tomcat systemd service file..."
sudo cat <<EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINA_BASE=/usr/local/tomcat
ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
SyslogIdentifier=tomcat-%i

[Install]
WantedBy=multi-user.target
EOF

if [ $? -ne 0 ]; then
    echo "Failed to create Tomcat service file. Exiting."
    exit 1
fi
echo "Tomcat systemd service file created successfully."

# Reload Systemd Daemon
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload || { echo "Failed to reload systemd daemon."; exit 1; }

# Start and Enable Tomcat Service
echo "Starting and enabling Tomcat service..."
sudo systemctl start tomcat || { echo "Failed to start Tomcat service."; exit 1; }
sudo systemctl enable tomcat || { echo "Failed to enable Tomcat service."; exit 1; }
echo "Tomcat service started and enabled successfully."

# Configure Firewall
echo "Configuring the firewall for Tomcat..."
sudo systemctl start firewalld || { echo "Failed to start firewalld."; exit 1; }
sudo systemctl enable firewalld || { echo "Failed to enable firewalld."; exit 1; }
sudo firewall-cmd --get-active-zones || { echo "Failed to get active zones."; exit 1; }
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent || { echo "Failed to open port 8080."; exit 1; }
sudo firewall-cmd --reload || { echo "Failed to reload firewall rules."; exit 1; }
echo "Firewall configured successfully."

# Variables
REPO_URL="https://github.com/hkhcoder/vprofile-project.git"
BRANCH="main"
PROJECT_DIR="vprofile-project"
TOMCAT_WEBAPPS="/usr/local/tomcat/webapps"
ARTIFACT="target/vprofile-v2.war"
BACKUP_DIR="/tmp/vprofile-backup"

# Step 1: Download Source Code
echo "Cloning the vProfile project repository..."
if [ ! -d "$PROJECT_DIR" ]; then
    git clone -b $BRANCH $REPO_URL || { echo "Failed to clone repository"; exit 1; }
else
    echo "Repository already exists. Pulling the latest changes..."
    cd $PROJECT_DIR && git pull || { echo "Failed to pull latest changes"; exit 1; }
    cd ..
fi
echo "Repository downloaded successfully."

# Step 2: Update Configuration
echo "Updating application.properties with backend server details..."
if [ -f "$PROJECT_DIR/src/main/resources/application.properties" ]; then
    # Backup the original file
    cp "$PROJECT_DIR/src/main/resources/application.properties" "$PROJECT_DIR/src/main/resources/application.properties.bak"
    # Edit the configuration (replace these lines with `sed` commands for automation if needed)
    echo "Please manually edit $PROJECT_DIR/src/main/resources/application.properties to update backend server details."
else
    echo "Configuration file not found: $PROJECT_DIR/src/main/resources/application.properties"
    exit 1
fi

# Step 3: Build the Code
echo "Building the vProfile project..."
cd $PROJECT_DIR || { echo "Failed to navigate to project directory"; exit 1; }
mvn install || { echo "Maven build failed"; exit 1; }
echo "Build completed successfully."

# Step 4: Deploy Artifact to Tomcat
echo "Deploying the application to Tomcat..."
# Stop Tomcat
sudo systemctl stop tomcat || { echo "Failed to stop Tomcat"; exit 1; }

# Backup existing ROOT application
echo "Backing up existing ROOT application..."
if [ -d "$TOMCAT_WEBAPPS/ROOT" ]; then
    mkdir -p $BACKUP_DIR
    mv "$TOMCAT_WEBAPPS/ROOT" "$BACKUP_DIR/ROOT-$(date +%F-%T)" || { echo "Failed to backup existing ROOT application"; exit 1; }
fi

# Remove existing ROOT artifacts
sudo rm -rf "$TOMCAT_WEBAPPS/ROOT*" || { echo "Failed to remove existing ROOT artifacts"; exit 1; }

# Copy the new WAR file to Tomcat
sudo cp "$ARTIFACT" "$TOMCAT_WEBAPPS/ROOT.war" || { echo "Failed to copy new WAR file"; exit 1; }

# Update permissions
sudo chown tomcat:tomcat "$TOMCAT_WEBAPPS" -R || { echo "Failed to update permissions"; exit 1; }

# Start Tomcat
sudo systemctl start tomcat || { echo "Failed to start Tomcat"; exit 1; }

# Restart Tomcat
sudo systemctl restart tomcat || { echo "Failed to restart Tomcat"; exit 1; }

echo "Application Machine provisioning completed successfully!"
