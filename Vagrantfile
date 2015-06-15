# -*- mode: ruby -*-
# -*- encoding: utf-8 -*-
# vi: set ft=ruby :

##   This Vagrantfile expects you to have puppet checked out and loads
## puppet's Vagrantfile. puppet_path: can be set in
## config/vagrant_config.yml or config/vagrant_user_config.yml if your
## puppet checkout is not at ../puppet

require 'yaml'

class GDConfMissing < Exception; end
gdconf     = ENV.fetch('VAGRANT_CONFIG',     './config/vagrant_config.yml')
gduserconf = ENV.fetch('VAGRANT_USER_CONFIG','./config/vagrant_user_config.yml')
File.exists?(gdconf) or raise GDConfMissing.new("config/vagrant_config.yml is missing for this project!")

# PROJ_CONFIG is being created here just to get at the puppet_path
# setting. These files will get loaded again by puppet's
# Vagrantfile. This is redundant but prevents some warnings about
# "already initialized constant CONFIG"
PROJ_CONFIG = YAML.load_file(gdconf)
if File.exists?(gduserconf)
  PROJ_CONFIG.merge!(YAML.load_file(gduserconf) || {})
end

## get the path to puppet checkout
prefix = PROJ_CONFIG.fetch('puppet_path','../puppet')

## load puppet's Vagrantfile
load "#{prefix}/Vagrantfile"
