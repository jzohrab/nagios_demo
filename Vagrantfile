Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 2
  end

  config.vm.define :server do |srv|
    srv.vm.hostname = "server"
    srv.vm.network "private_network", ip: "192.168.33.10"
    srv.vm.synced_folder "server/", "/usr/local/nagios/etc", create: true
    srv.vm.network "forwarded_port", guest: 80, host: 8080
    srv.vm.provision "shell", path: "provision_server.sh"
  end

  config.vm.define :client do |cl|
    cl.vm.hostname = "client"
    cl.vm.network "private_network", ip: "192.168.33.11"
    cl.vm.synced_folder "client/", "/usr/local/nagios/etc", create: true
    cl.vm.provision "shell", path: "provision_client.sh"
  end
end
