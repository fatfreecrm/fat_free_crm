# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/xenial64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    git clone https://github.com/fatfreecrm/fat_free_crm.git
    cd fat_free_crm
    cp config/database.postgres.yml config/database.yml
    apt-get install -y nginx-full postgresql ruby-all-dev ruby-bundler libmagick++-dev libxml2 libxml2-dev libxslt1.1 libxslt1-dev libyaml-dev libpq-dev libsqlite3-dev
    bundle install
    echo "ALTER USER postgres PASSWORD '123456';" | sudo -u postgres psql
    sed -i 's/  username:/  username: postgres/g' 'config/database.yml'
    sed -i 's/  password:/  password: '123456'/g' 'config/database.yml'
    rake db:setup
    rake ffcrm:setup:admin USERNAME=admin PASSWORD=password EMAIL=admin@example.com
    rm -rf /etc/nginx/sites-available/default
    echo "server {" > /etc/nginx/sites-available/default
    echo "  listen 80;" >> /etc/nginx/sites-available/default
    echo "  location / {" >> /etc/nginx/sites-available/default
    echo "    proxy_pass http://localhost:3000;" >> /etc/nginx/sites-available/default
    echo "  }" >> /etc/nginx/sites-available/default
    echo "}" >> /etc/nginx/sites-available/default
    sudo systemctl stop nginx
    sudo systemctl start nginx
    rails s
  SHELL
end
