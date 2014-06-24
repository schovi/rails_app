#
# Cookbook Name:: rubygems_app
# Recipe:: default
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#

include_recipe "rvm::user_install"

user_account 'rubygems_app' do
  action :create
end

package 'git' do 
  action :install
end

node.default['rvm']['user_installs'] = [
  { 'user'          => 'rubygems_app',
    'default_ruby'  => '2.0.0',
    'rubies'        => ['2.0.0']
  }
]

application 'my-app' do
  path '/home/rubygems_app'
  repository 'https://github.com/rubygems/rubygems.org.git'
  revision 'master'
end

#unicorn



# Copyright (C) 2014 Erich Kaderka
#
# All rights reserved - Do Not Redistribute
#

