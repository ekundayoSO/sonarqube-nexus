#!/bin/bash

# Update and install Java & Tomcat 9
sudo apt update -y
sudo apt install openjdk-11-jdk -y
sudo apt-get install tomcat9 tomcat9-docs tomcat9-admin -y

# Copy admin webapps if needed (usually already deployed)
sudo cp -r /usr/share/tomcat9-admin/* /var/lib/tomcat9/webapps/ -v

# Backup tomcat-users.xml
sudo cp /var/lib/tomcat9/conf/tomcat-users.xml /var/lib/tomcat9/conf/tomcat-users.xml.bak

# Insert roles & users before closing </tomcat-users>
sudo sed -i '/<\/tomcat-users>/i \
<role rolename="manager-script"/>\n\
<role rolename="admin-gui"/>\n\
<role rolename="manager-gui"/>\n\
<user username="tomcat" password="password" roles="manager-script"/>\n\
<user username="admin" password="admin" roles="admin-gui,manager-gui"/>' /var/lib/tomcat9/conf/tomcat-users.xml

# Set appropriate permissions
sudo chmod 777 /var/lib/tomcat9/conf/tomcat-users.xml
sudo chown root:tomcat /var/lib/tomcat9/conf/tomcat-users.xml

# Restart Tomcat
sudo systemctl restart tomcat9

echo 'Tomcat 9 installed and configured successfully.'
