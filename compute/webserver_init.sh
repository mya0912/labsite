#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
cd /var/www/html
sudo touch index.html
sudo chmod 770 index.html
sudo su
echo "Labsite Webserver Test Page" > index.html
chown -R apache:apache /var/www/html/
systemctl start httpd
chkconfig httpd on

#these commands are to install the aws monitoring agent and configure, look into this more
#wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
#sudo rpm -U ./amazon-cloudwatch-agent.rpm
#sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -s
