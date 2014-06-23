#
# Cookbook Name:: rubygems_app
# Recipe:: default
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#


user_account 'rubygems_app' do
  action :create
end

application 'my-app' do
  path '/home/rubygems_app'
  repository 'https://github.com/rubygems/rubygems.org.git'
  revision 'master'

  unicorn do
    port '8000'
    worker_processes '2'
  end
end
# Copyright (C) 2014 Erich Kaderka
#
# All rights reserved - Do Not Redistribute
#

