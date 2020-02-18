SERVER_COUNT = 3
CONSUL_VER = "1.6.2"
LOG_LEVEL = "debug" #The available log levels are "trace", "debug", "info", "warn", and "err". if empty - default is "info"
DOMAIN = "denislav"
TLS = true
VAULT = "1.2.3+ent"


Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: false
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 4
  
  end

  

  ["sofia",].to_enum.with_index(1).each do |dcname, dc|

   
    
    (1..SERVER_COUNT).each do |i|
      
      config.vm.define "consul-server#{i}-#{dcname}" do |node|
        node.vm.box = "denislavd/xenial64"
        node.vm.hostname = "consul-server#{i}-#{dcname}"
        node.vm.provision :shell, path: "scripts/install_consul.sh", env: {"CONSUL_VER" => CONSUL_VER}
        node.vm.provision :shell, path: "scripts/start_consul.sh", env: {"SERVER_COUNT" => SERVER_COUNT,"LOG_LEVEL" => LOG_LEVEL,"DOMAIN" => DOMAIN,"DCS" => "#{dcname}","DC" => "#{dc}","TLS" => TLS}
        # node.vm.provision :shell, path: "scripts/keyvalue.sh", env: {"I" => "#{dc}","TLS" => TLS}
        node.vm.network "private_network", ip: "10.#{dc}0.56.1#{i}"
        node.vm.network "forwarded_port", guest: 8500, host: 8500 + i
      end
    end

    if TLS 
      config.vm.define "client-vault-server1-#{dcname}" do |vault|
        vault.vm.box = "denislavd/xenial64"
        vault.vm.hostname = "client-vault-server1-#{dcname}"
        vault.vm.provision :shell, path: "scripts/install_consul.sh", env: {"CONSUL_VER" => CONSUL_VER}
        vault.vm.provision :shell, path: "scripts/start_consul.sh", env: {"SERVER_COUNT" => SERVER_COUNT,"LOG_LEVEL" => LOG_LEVEL,"DOMAIN" => DOMAIN,"DCS" => "#{dcname}","DC" => "#{dc}","TLS" => TLS}
        vault.vm.provision :shell, path: "scripts/install_vault.sh", env: {"VAULT" => VAULT,"DOMAIN" => DOMAIN}
        vault.vm.network "private_network", ip: "10.#{dc}0.46.11"
      end

      config.vm.define "client-vault-server2-#{dcname}" do |vault|
        vault.vm.box = "denislavd/xenial64"
        vault.vm.hostname = "client-vault-server2-#{dcname}"
        vault.vm.provision :shell, path: "scripts/install_consul.sh", env: {"CONSUL_VER" => CONSUL_VER}
        vault.vm.provision :shell, path: "scripts/start_consul.sh", env: {"SERVER_COUNT" => SERVER_COUNT,"LOG_LEVEL" => LOG_LEVEL,"DOMAIN" => DOMAIN,"DCS" => "#{dcname}","DC" => "#{dc}","TLS" => TLS}
        vault.vm.provision :shell, path: "scripts/install_vault.sh", env: {"VAULT" => VAULT,"DOMAIN" => DOMAIN}
        vault.vm.network "private_network", ip: "10.#{dc}0.46.12"
      end

      config.vm.define "client-vault-server3-#{dcname}" do |vault|
        vault.vm.box = "denislavd/xenial64"
        vault.vm.hostname = "client-vault-server3-#{dcname}"
        vault.vm.provision :shell, path: "scripts/install_consul.sh", env: {"CONSUL_VER" => CONSUL_VER}
        vault.vm.provision :shell, path: "scripts/start_consul.sh", env: {"SERVER_COUNT" => SERVER_COUNT,"LOG_LEVEL" => LOG_LEVEL,"DOMAIN" => DOMAIN,"DCS" => "#{dcname}","DC" => "#{dc}","TLS" => TLS}
        vault.vm.provision :shell, path: "scripts/install_vault.sh", env: {"VAULT" => VAULT,"DOMAIN" => DOMAIN}
        vault.vm.network "private_network", ip: "10.#{dc}0.66.13"
      end

      config.vm.define "client-vault-server4-#{dcname}" do |vault|
        vault.vm.box = "denislavd/xenial64"
        vault.vm.hostname = "client-vault-server4-#{dcname}"
        vault.vm.provision :shell, path: "scripts/install_consul.sh", env: {"CONSUL_VER" => CONSUL_VER}
        vault.vm.provision :shell, path: "scripts/start_consul.sh", env: {"SERVER_COUNT" => SERVER_COUNT,"LOG_LEVEL" => LOG_LEVEL,"DOMAIN" => DOMAIN,"DCS" => "#{dcname}","DC" => "#{dc}","TLS" => TLS}
        vault.vm.provision :shell, path: "scripts/install_vault.sh", env: {"VAULT" => VAULT,"DOMAIN" => DOMAIN}
        vault.vm.network "private_network", ip: "10.#{dc}0.66.14"
      end

    end

  end
end