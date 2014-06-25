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

#it helps with debugging
package 'tmux' do
  action :install
end

#Fix Could not find a JavaScript runtime. See https://github.com/sstephenson/execjs for a list of available runtimes. (ExecJS::RuntimeUnavailable) on Debian - starting rails app
package 'libv8-dev' do
  action :install
end

#Install development headers for mysql required by mysql2 gem

package 'libmysqlclient-dev' do
  action :install
end

application node['name'] do
  owner 'rubygems_app'
  group 'rubygems_app'
  path '/home/rubygems_app'
  repository 'https://github.com/erich/simple-rails.git'
  revision 'master'
  rails do
    database do
      database "rubygems_app_production"
      username "rubygems_app"
      password "12*asda!BanqV"
    end
  end
end

rvm_shell "bundle" do
  ruby_string 'ruby-2.0.0@rubygems_app'
  user        "rubygems_app"
  group       "rubygems_app"
  cwd         "/home/rubygems_app/current"
  #path        "home/rubygems_app/.rvm/gems/ruby-2.0.0-rc1@rubygems_app:/home/rubygems_app/.rvm/gems/ruby-2.0.0-rc1@global"
  code        <<-EOF
    bundle install #--path .bundle
  EOF
end

#add rvm bashrc config line
rvm_line = '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"'
ruby_block "add rvm basrhc config line" do
  block do
    #NOTE move this to attributes
    file = Chef::Util::FileEdit.new("/home/rubygems_app/.bashrc")
    file.insert_line_if_no_match(rvm_line, rvm_line)
    file.write_file
  end
end

#NOTE it raises weird debian syntax error on line 6
#ruby_block "reload .bashrc" do
#  block do
#    Chef::Config.from_file("/home/rubygems_app/.bashrc")
#  end
#end


unicorn_config "/etc/unicorn/rubygems_app.rb" do
  listen({ node[:unicorn][:port] => node[:unicorn][:options] })
  working_directory ::File.join(node['name'], 'current')
  worker_timeout node[:unicorn][:worker_timeout]
  preload_app node[:unicorn][:preload_app]
  worker_processes node[:unicorn][:worker_processes]
  before_fork node[:unicorn][:before_fork]
end

gem_package "unicorn" do
  action :install
end

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
