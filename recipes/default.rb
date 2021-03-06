#
# Cookbook Name:: rails_app
# Recipe:: default
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#

# TODO do configu
ENV['RACK_ENV'] = ENV['RAILS_ENV'] = node.rails_app['environment']

include_recipe "nginx"

#FIXME maybe not needed, add rvm bashrc config line
rvm_line = '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"'
ruby_block "add rvm basrhc config line" do
  block do
    #FIXME move this to attributes
    file = Chef::Util::FileEdit.new("/home/#{node['rails_app']['name']}/.bashrc")
    file.insert_line_if_no_match(rvm_line, rvm_line)
    file.write_file
  end
end

unicorn_config node['unicorn']['config_file'] do
  listen({ node['unicorn']['port'] => node['unicorn']['options'] })

  working_directory "#{node['rails_app']['application_path']}/current"
  worker_timeout    node['unicorn']['worker_timeout']
  preload_app       node['unicorn']['preload_app']
  worker_processes  node['unicorn']['worker_processes']
  before_fork       node['unicorn']['before_fork']
  pid               node['unicorn']['pid']
  stderr_path       node['unicorn']['stderr_path']
  stdout_path       node['unicorn']['stdout_path']
end

rvm_shell "run bundle install" do
  user  node['rails_app']['name']
  group node['rails_app']['name']
  cwd   "#{node['rails_app']['application_path']}/current"

  code  <<-EOF
    bundle instal --without development test doc
  EOF
end

file "#{node['nginx']['dir']}/sites-available/#{node['rails_app']['domain']}" do
  owner node['rails_app']['name']
  mode  "0644"
end

template "/etc/nginx/sites-available/#{node['rails_app']['domain']}" do
  source "nginx_site.erb"
  mode "644"
  variables(
    :application_name => node['rails_app']['domain'],
    :application_path => node['rails_app']['application_path'],
    :unicorn_port => node['unicorn']['port']
  )
end

# enable your sites configuration using a definition from the nginx cookbook
nginx_site node['rails_app']['domain'] do
  enable true
end

template "/etc/monit/conf.d/#{node.rails_app[:name]}.conf" do
  owner "root"
  group "root"
  mode 0644
  source "monit.conf.erb"
  action :create
end

execute "reload monit" do
  command "monit reload"
  user "root"
  group "root"
end

execute "restart monit service" do
  command "sleep 1 && monit -g #{node.rails_app[:name]} restart"
  user "root"
  group "root"
end



# Copyright (C) 2014 Erich Kaderka
#
# All rights reserved - Do Not Redistribute
#
