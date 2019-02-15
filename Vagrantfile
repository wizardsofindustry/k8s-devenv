# -*- mode: ruby -*-
# vi: set ft=ruby :
system 'mkdir', '-p', 'var/ci/jenkins'
system 'mkdir', '-p', 'var/ci/gitlab'
system 'mkdir', '-p', 'etc/ci/gitlab'

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

  #config.vm.define "k8s" do |k8s|
  #  k8s.vm.provision "shell",
  #    path: "provision-ca.sh",
  #    env: {"PKI_DIR" => "/etc/pki"}
  #  k8s.vm.network "private_network", ip: "10.17.1.10"
  #  k8s.vm.network "forwarded_port", guest: 8001, host: 8001
  #  k8s.vm.provision "shell",
  #    path: "provision-ca.sh",
  #    env: {
  #      "PKI_DIR" => "/etc/pki",
  #      "DEBIAN_FRONTEND" => "noninteractive"
  #    }
  #  k8s.vm.provision 'shell', path: "provision.sh"
  #  k8s.vm.synced_folder "pki", "/etc/pki"
  #  k8s.vm.provider "virtualbox" do |v|
  #    v.memory = 4096
  #    v.cpus = 4
  #  end
  #end

  config.vm.define "artifacts" do |artifacts|
    artifacts.vm.network "private_network", ip: "10.17.3.10"
    artifacts.vm.synced_folder "pki", "/etc/pki"
    artifacts.vm.provision 'shell', path: "etc/common/provision-docker.sh"
    artifacts.vm.provision "shell",
      path: "etc/common/provision-ca.sh",
      env: {
        "PKI_DIR" => "/etc/pki",
        "DEBIAN_FRONTEND" => "noninteractive"
      }
    artifacts.vm.provision "shell",
      path: "etc/artifacts/provision.sh",
      env: {
        "PKI_DIR" => "/etc/pki",
        "CONFIG_DIR" => "/vagrant/etc/artifacts",
        "DEBIAN_FRONTEND" => "noninteractive"
      }
  end

  #config.vm.define "ci" do |ci|
  #  ci.vm.box = "ubuntu/xenial64"
  #  ci.vm.network "private_network", ip: "10.17.2.10"
  #  ci.vm.network "private_network", ip: "10.17.2.11"
  #  ci.vm.synced_folder "var/ci/jenkins", "/var/lib/jenkins"
  #  ci.vm.synced_folder "var/ci/gitlab", "/var/lib/gitlab"
  #  ci.vm.synced_folder "etc/ci/gitlab", "/etc/gitlab"
  #  ci.vm.synced_folder "pki", "/etc/pki"
  #end
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

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
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
