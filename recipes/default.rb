#
# Cookbook Name:: rubygems_app
# Recipe:: default
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#

include_recipe "nginx"


user_account node['name'] do
  action :create
end

package 'git' do
  action :install
end


application node['name'] do
  path ['node']['application_path']
  repository 'https://github.com/erich/simple-rails.git'
  revision 'master'
end

#add rvm bashrc config line
rvm_line = '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"'
ruby_block "add rvm basrhc config line" do
  block do
    #NOTE move this to attributes
    file = Chef::Util::FileEdit.new("#{['node']['basrhc']}")
    file.insert_line_if_no_match(rvm_line, rvm_line)
    file.write_file
  end
end

ruby_block "reload .bashrc" do
  block do
    Chef::Config.from_file("#{['node']['basrhc']}")
  end
  action :nothing
end

execute "cd to app directory, run bundle install and restart unicorn" do
  user ['node']
  #NOTE split to mulitple lines maybe 2 execute
  command "cd #{['node']['application_path']} && bundle install && bundle exec unicorn -c #{['node']['unicorn']['config_file']}"
end

unicorn_config "#{['node']['unicorn']['config_file']}" do
  listen({ node[:unicorn][:port] => node[:unicorn][:options] })
  working_directory ::File.join(node['name'], 'current')
  worker_timeout node[:unicorn][:worker_timeout]
  preload_app node[:unicorn][:preload_app]
  worker_processes node[:unicorn][:worker_processes]
  before_fork node[:unicorn][:before_fork]
end

#nginx -> it should have its own cookbook

file "#{node['nginx']['dir']}/sites-available/#{node['domain']}" do
  owner node['name']
  mode  "0644"
end

template "/etc/nginx/sites-available/#{node['domain']}" do
    source "nginx_site.erb"
    mode 644
    variables(
      :application_name => node['domain'],
      :application_path => node['application_path'],
      :unicorn_port => node['unicorn']['port']
    )
  end

# enable your sites configuration using a definition from the nginx cookbook
nginx_site node['domain'] do
  enable true
end



# Copyright (C) 2014 Erich Kaderka
#
# All rights reserved - Do Not Redistribute
#
