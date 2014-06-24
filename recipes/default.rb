#
# Cookbook Name:: rubygems_app
# Recipe:: default
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#

include_recipe "nginx"

node['default']['app_name'] = 'rubygems_app'
node['default']['domain'] = "#{node['default']['app_name']}.com"

user_account node['default']['app_name'] do
  action :create
end

package 'git' do 
  action :install
end


application node['default']['app_name'] do
  path '/home/rubygems_app'
  repository 'https://github.com/rubygems/rubygems.org.git'
  revision 'master'
end

#unicorn

node.default[:unicorn][:worker_timeout] = 60
node.default[:unicorn][:preload_app] = false
node.default[:unicorn][:worker_processes] = [node[:cpu][:total].to_i * 4, 8].min
node.default[:unicorn][:preload_app] = false
node.default[:unicorn][:before_fork] = 'sleep 1'
node.default[:unicorn][:port] = '8080'
node.set[:unicorn][:options] = { :tcp_nodelay => true, :backlog => 100 }

unicorn_config "/etc/unicorn/#{app['id']}.rb" do
  listen({ node[:unicorn][:port] => node[:unicorn][:options] })
  working_directory ::File.join(app['deploy_to'], 'current')
  worker_timeout node[:unicorn][:worker_timeout]
  preload_app node[:unicorn][:preload_app]
  worker_processes node[:unicorn][:worker_processes]
  before_fork node[:unicorn][:before_fork]
end

#nginx -> it should have its own cookbook

cookbook_file "#{node['nginx']['dir']}/sites-available/#{node['default']['domain']}" do
  owner node['default']['app_name']
  mode  "0644"
end

template "/etc/nginx/sites-available/#{node['default']['domain']}" do
    source "nginx_site.erb"
    mode 644
    variables(
      :application_name => node['default']['domain'],
      :default => default,
      :unicorn_port => node['default']['unicorn']['port']
    )
  end

# enable your sites configuration using a definition from the nginx cookbook
nginx_site node['default']['domain'] do
  enable true
end



# Copyright (C) 2014 Erich Kaderka
#
# All rights reserved - Do Not Redistribute
#

