#!/bin/bash

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Java 17 (required for Jenkins)
sudo apt install -y openjdk-17-jdk

# Verify Java installation
java -version

# Add Jenkins repository and install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins

# Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Maven
sudo apt install -y maven

# Verify Maven installation
mvn -version

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install -y terraform

# Verify Terraform installation
terraform -version

# Install additional useful tools
sudo apt install -y git curl wget unzip

# Configure firewall (if ufw is enabled)
sudo ufw allow 8080/tcp
sudo ufw allow 22/tcp

# Display Jenkins initial admin password
echo "=========================================="
echo "Jenkins Setup Complete!"
echo "=========================================="
echo "Jenkins URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo ""
echo "Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo ""
echo "Java Version:"
java -version
echo ""
echo "Maven Version:"
mvn -version
echo ""
echo "Terraform Version:"
terraform -version
echo "=========================================="