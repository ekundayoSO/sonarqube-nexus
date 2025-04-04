#!/bin/bash

set -e  # Exit immediately if a command fails

echo "Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

echo "Installing Java 17 (OpenJDK 17)..."
sudo apt install openjdk-17-jdk -y

echo "Creating Nexus user..."
sudo useradd -m -d /opt/nexus -s /bin/bash nexus || echo "User nexus already exists"
echo "nexus ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/nexus

echo "Downloading the latest stable version of Nexus 3..."
cd /opt
NEXUS_VERSION="3.66.0-02"  # Update if needed
NEXUS_DIR="nexus-${NEXUS_VERSION}"
sudo wget -O nexus.tar.gz "https://download.sonatype.com/nexus/3/${NEXUS_DIR}-unix.tar.gz"

echo "Extracting Nexus..."
sudo tar -xvzf nexus.tar.gz

# Remove the existing 'nexus' directory if it exists
if [ -d "/opt/nexus" ]; then
    echo "Removing existing /opt/nexus directory..."
    sudo rm -rf /opt/nexus
fi

# Rename the extracted directory to 'nexus'
sudo mv "${NEXUS_DIR}" nexus

# Ensure correct permissions
sudo mkdir -p /opt/sonatype-work
sudo chown -R nexus:nexus /opt/nexus /opt/sonatype-work

echo "Ensuring Nexus bin directory exists..."
if [ ! -d "/opt/nexus/bin" ]; then
    echo "Error: /opt/nexus/bin directory not found. Extraction might have failed."
    exit 1
fi

echo "Configuring Nexus to run as a service..."
echo 'run_as_user="nexus"' | sudo tee /opt/nexus/bin/nexus.rc

echo "Creating systemd service for Nexus..."
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOF
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
User=nexus
Group=nexus
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
Restart=on-abort
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd, enabling and starting Nexus service..."
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

echo "Checking Nexus status..."
sudo systemctl status nexus --no-pager

echo "Nexus installation completed successfully!"
echo "Access Nexus at: http://$(hostname -I | awk '{print $1}'):8081"
echo "Admin password can be found at: /opt/sonatype-work/nexus3/admin.password"
