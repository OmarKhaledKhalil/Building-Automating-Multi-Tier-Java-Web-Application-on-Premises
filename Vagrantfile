
Vagrant.configure("2") do |config|
  config.hostmanager.enabled = true 
  config.hostmanager.manage_host = true

### Define Nagios Machine ###

  config.vm.define "ng01" do |ng01|
    ng01.vm.box = "eurolinux-vagrant/centos-stream-9"
    ng01.vm.box_version = "9.0.43"
    ng01.vm.hostname = "ng01"
    ng01.vm.network "private_network", ip: "192.168.56.16"
    ng01.vm.provider "virtualbox" do |vb|
     vb.memory = "600"
   end

    # Add the shell provisioner
     ng01.vm.provision "shell", path: "Nagios_Script.sh"

 end


### Define DB Machine  ####
  config.vm.define "db01" do |db01|
    db01.vm.box = "eurolinux-vagrant/centos-stream-9"
    db01.vm.box_version = "9.0.43"
    db01.vm.hostname = "db01"
    db01.vm.network "private_network", ip: "192.168.56.15"
    db01.vm.provider "virtualbox" do |vb|
     vb.memory = "600"
   end

    # Add the shell provisioner
     db01.vm.provision "shell", path: "Data_Base_Script.sh"
 
 end
  
### Memcache vm  #### 
  config.vm.define "mc01" do |mc01|
    mc01.vm.box = "eurolinux-vagrant/centos-stream-9"
    mc01.vm.box_version = "9.0.43"
    mc01.vm.hostname = "mc01"
    mc01.vm.network "private_network", ip: "192.168.56.14"
    mc01.vm.provider "virtualbox" do |vb|
     vb.memory = "600"
   end
 # Add the shell provisioner
    mc01.vm.provision "shell", path: "MemCache_Script.sh"
 
 end
  
### RabbitMQ vm  ####
  config.vm.define "rmq01" do |rmq01|
    rmq01.vm.box = "eurolinux-vagrant/centos-stream-9"
    rmq01.vm.box_version = "9.0.43"
    rmq01.vm.hostname = "rmq01"
    rmq01.vm.network "private_network", ip: "192.168.56.13"
    rmq01.vm.provider "virtualbox" do |vb|
     vb.memory = "600"
   end

 # Add the shell provisioner
    rmq01.vm.provision "shell", path: "RABBITMQ_Script.sh"

  end
  
### tomcat vm ###
   config.vm.define "app01" do |app01|
    app01.vm.box = "eurolinux-vagrant/centos-stream-9"
    app01.vm.box_version = "9.0.43"
    app01.vm.hostname = "app01"
    app01.vm.network "private_network", ip: "192.168.56.12"
    app01.vm.provider "virtualbox" do |vb|
     vb.memory = "800"
   end

  # Add the shell provisioner
    app01.vm.provision "shell", path: "Tomcat_Script.sh"

   end
   
  
### Nginx VM ###
  config.vm.define "web01" do |web01|
    web01.vm.box = "ubuntu/jammy64"
    web01.vm.hostname = "web01"
  web01.vm.network "private_network", ip: "192.168.56.11"
  web01.vm.provider "virtualbox" do |vb|
     vb.gui = true
     vb.memory = "800"
   end

# Add the shell provisioner
    web01.vm.provision "shell", path: "Nginx_Script.sh"

end
  
end
