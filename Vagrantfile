# -*- encoding: utf-8 -*-
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Config files:
# config/vagrant_config.yml
# config/vagrant_user_config.yml
# can be overwritten with shell env vars VAGRANT_CONFIG,VAGRANT_USER_CONFIG

# Manage your host with the name you used in the config file.
# For example,
# vagrant up zk1 # brings up host zk1
# vagrant up     # brings up all hosts

## you can create a ~/vagrantfiles directory with .bashrc,
## .bash_aliases, and bin and it will be linked in user vagrant's home
## direcory

## Load Config files
require 'yaml'
class GDConfMissing < Exception; end
gdconf     = ENV.fetch('VAGRANT_CONFIG',     './config/vagrant_config.yml')
gduserconf = ENV.fetch('VAGRANT_USER_CONFIG', './config/vagrant_user_config.yml')
File.exist?(gdconf) || raise(GDConfMissing.new('cp config/vagrant_config_example.yml config/vagrant_example.yml or set VAGRANT_CONFIG,VAGRANT_USER_CONFIG'))

CONFIG = YAML.load_file(gdconf)
CONFIG.merge!(YAML.load_file(gduserconf) || {}) if File.exist?(gduserconf)

## Home directory customization
$home_customization = <<HOMECUST
[[ -L /home/vagrant/.bashrc ]] ||       { echo 'setup .bashrc';       mv /home/vagrant/.bashrc /home/vagrant/.bashrc.bak && ln -s /vagrantfiles/home/vagrant/.bashrc /home/vagrant/.bashrc; }
[[ -L /home/vagrant/.bash_aliases ]] || { echo 'setup .bash_aliases'; ln -s /vagrantfiles/home/vagrant/.bash_aliases /home/vagrant/.bash_aliases; }
[[ -L /home/vagrant/bin ]] ||           { echo 'setup bin';           ln -s /vagrantfiles/home/vagrant/bin /home/vagrant/bin; }
HOMECUST

Vagrant.configure('2') do |config|
  config.vm.box = 'base-build'
  config.vm.box_url = 'http://prod-foreman1-ep.tops.gdi/distros/base-build-1.0.box'

  CONFIG['hosts'].each do |name, host_config|
    config.vm.define(name) do |guest|
      number     = name =~ /\d$/ ? nil : 1 # if name endswith \d don't append 1
      hostname   = "dev-#{name}#{number}" # number required in hostname
      domainname = 'local.gdi'
      fqdn       = "#{hostname}.#{domainname}"

      guest.vm.hostname = "#{fqdn}"

      # write to local /etc/hosts
      if defined?(VagrantPlugins::HostsUpdater)
        if host_config['ip']
          guest.hostsupdater.aliases = ["#{name}.dev"]
        else
          puts "not using a private network so no .dev entries created for #{name}"
        end
      else
        puts 'not using vagrant-hostsupdater plugin run `vagrant plugin install vagrant-hostsupdater`'
      end

      # write to guest /etc/hosts
      if defined?(VagrantHosts)
        if host_config['ip']
          guest.vm.provision :hosts do |provisioner|
            provisioner.add_localhost_hostnames = false   ## stop adding 127.0.1.1
            # TODO: confirm that autoconfigure is the same as the below
            provisioner.autoconfigure = true
            # For each entry in the config file, we add an entry
            # in this host's resolv.conf (including for itself)
            # CONFIG['hosts'].each do |_, host_config|

            #   provisioner.add_host host_config['ip'], host_config['host']
            # end
          end
        end
      else
        puts 'not using vagrant-hosts plugin run `vagrant plugin install vagrant-hosts`'
      end

      ## setup user customized home directory files
      if File.directory?("#{ENV['HOME']}/vagrantfiles")
        guest.vm.synced_folder '~/vagrantfiles', '/vagrantfiles'
        guest.vm.provision :shell, inline: $home_customization
      end

      # Port forwarding
      if host_config['ports']
        host_config['ports'].each do |port_set|
          guest.vm.network 'forwarded_port', host: port_set.fetch('host'), guest: port_set.fetch('guest')
        end
      end

      # Private (host-only) network
      if host_config['ip']
        guest.vm.network 'private_network', ip: host_config['ip']
        # restart network if this interface is missing
        guest.vm.provision :shell, inline: "ip addr show eth1 | grep -q #{host_config['ip']} || /sbin/ifup eth1"
      end

      # configure machine
      guest.vm.provider 'virtualbox' do |vb|
        # vm.gui = true
        # centos bug: https://github.com/mitchellh/vagrant/issues/1172#issuecomment-9444659
        vb.customize ['modifyvm', :id, '--natdnsproxy1', 'off']
        vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'off']
        vb.customize ['modifyvm', :id, '--memory', host_config['ram']] if host_config['ram']
      end

      ## mounts
      unless (mounts = CONFIG['mounts'] + host_config.fetch('mounts', [])).empty?
        mounts.each do |mount|
          guest.vm.synced_folder mount.fetch('host'), mount.fetch('guest'), create: true
        end
      end

      # provision with puppet
      prefix = CONFIG.fetch('puppet_path', '../puppet')
      guest.vm.synced_folder "#{prefix}/hieradata",         '/opt/puppet-deploy/dev/current/hieradata/' # must match hostname env
      guest.vm.synced_folder "#{prefix}/hieradata/private", '/opt/puppet-private/' ## private local data

      guest.vm.provision :puppet do |puppet|
        # `vagrant provision` runs:
        # puppet apply --modulepath '/etc/puppet/modules:/tmp/vagrant-puppet/modules-0:/tmp/vagrant-puppet/modules-1' --hiera_config=/tmp/vagrant-puppet/hiera.yaml --manifestdir /tmp/vagrant-puppet/manifests --detailed-exitcodes /tmp/vagrant-puppet/manifests/default.pp || [ $? -eq 2 ]

        # add puppet submodule:
        # git submodule add -b master --force git@dev-scm.office.gdi:puppet/puppet.git puppet

        puppet.options = '--debug' if ENV['DEBUG']
        puppet.hiera_config_path = "#{prefix}/hieradata/hiera.yaml"
        puppet.manifests_path    = "#{prefix}/manifests"
        puppet.manifest_file     = 'site.pp'
        puppet.module_path       = ["#{prefix}/modules", "#{prefix}/contrib"]
      end
    end
  end
end
