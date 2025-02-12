                                          **Building & Automating Multi-Tier Java Web Application on Premises**


**Project Overview**
This project focuses on deploying and automating a Multi-Tier Java Web Application on a local infrastructure using VirtualBox and Vagrant. The application follows a multi-tier architecture, including:

Web Layer: Nginx (Reverse Proxy)
Application Layer: Apache Tomcat (Running Java WAR Application)
Database Layer: MySQL
Caching Layer: Memcached
Message Queueing: RabbitMQ
Monitoring: Nagios
The setup is fully automated using Shell scripts, making deployment scalable and repeatable.

Project Goals
✔ Deploy a Java Web Application in a multi-tier architecture
✔ Automate infrastructure setup using Vagrant & Shell scripts
✔ Configure Nginx as a reverse proxy
✔ Deploy Tomcat as an application server with a WAR file
✔ Set up MySQL as the database
✔ Implement Memcached for caching
✔ Configure RabbitMQ for message queuing
✔ Use Nagios for monitoring system health and performance

**Architecture Overview**
The project consists of six virtual machines (VMs), each serving a dedicated function:

Machine	  Role	                      IP Address	     Software/Tools
db01	    Database Server	            192.168.56.10	    MySQL
mc01	    Caching Layer	              192.168.56.11	    Memcached
rmq01	    Message Queueing	          192.168.56.12	    RabbitMQ
app01	    Application Server (Tomcat)	192.168.56.13	    Apache Tomcat, Java, Spring Boot
web01	    Web Server (Reverse Proxy)	192.168.56.14	    Nginx
ng01	    Monitoring Server	          192.168.56.15	    Nagios

**Technologies Used**
Virtualization: VirtualBox
Provisioning & Automation: Vagrant, Shell Scripting
Operating System: CentOS 9 / Ubuntu
Web Server: Nginx
Application Server: Apache Tomcat
Database: MySQL
Caching: Memcached
Message Queueing: RabbitMQ
Monitoring: Nagios

Project Setup
1. Install Required Tools
**Ensure the following dependencies are installed**:
sudo apt update && sudo apt install -y virtualbox vagrant git

2. Clone the Repository

git clone https://github.com/OmarKhaledKhalil/Building-Automating-Multi-Tier-Java-Web-Application-on-Premises.git
cd Building-Automating-Multi-Tier-Java-Web-Application-on-Premises

3. Start the Environment
#Run the following command to provision all VMs:
vagrant up

This will:

Create all six virtual machines
Install and configure the required software
Deploy the Java web application on Tomcat
Set up monitoring using Nagios
Automated Provisioning
Each machine is automatically configured using Shell scripts, located in the scripts/ directory:

**Script	Purpose**
Data_Base_Script.sh	Installs and configures MySQL on db01.
MemCache_Script.sh	Sets up Memcached on mc01.
RABBITMQ_Script.sh	Installs RabbitMQ on rmq01.
Tomcat_Script.sh	Configures Apache Tomcat & deploys WAR on app01.
Nginx_Script.sh	Configures Nginx as a reverse proxy on web01.
Nagios_Script.sh	Installs and sets up Nagios monitoring on ng01.

**Accessing the Application**
1. Web Application (Nginx Reverse Proxy)
Open a browser and navigate to:
👉 http://192.168.56.14
This should display the Java Web Application.
2. Tomcat Application Server
Direct access to Tomcat:
👉 http://192.168.56.13:8080
3. Nagios Monitoring Dashboard
To monitor all VMs:
👉 http://192.168.56.15/nagios
Username: nagiosadmin
Password: nagios
Managing the Environment

**Start a Specific Machine**
vagrant up db01
**Stop a Machine**
vagrant halt db01

**Destroy All Machines**
#If you need to reset everything:
vagrant destroy -f

**Re-Provision a Machine**
#If you make changes to a provisioning script, re-run:
vagrant provision db01

**Troubleshooting**

#Check VM Status
vagrant status

#SSH into a VM
vagrant ssh db01

**Check Running Services**
#For MySQL on db01:
sudo systemctl status mariadb
#For Nginx on web01:
sudo systemctl status nginx

**Check Nagios Logs**
#If monitoring isn’t working, check logs:
sudo tail -f /usr/local/nagios/var/nagios.log

**Future Improvements**
🚀 Automate using Ansible instead of shell scripts
🚀 Deploy on AWS Cloud instead of local setup
🚀 Use Docker & Kubernetes for containerized deployment

Author
👤 Omar Khaled Khalil
📧 Email: omar.khaled.ahmed.khalil@gmail.com
🔗 LinkedIn: https://www.linkedin.com/in/omar-khaled-70a3191a2
