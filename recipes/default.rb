#
# Cookbook Name:: rubygems_app
# Recipe:: default
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#

include_recipe "nginx"



rvm_shell "bundle" do
  ruby_string node['rubygems_app']['ruby_rvm_version']
  user        node['rubygems_app']['name']
  group       node['rubygems_app']['name']
  cwd         "#{node['rubygems_app']['application_path']}/current"
  #path        "home/rubygems_app/.rvm/gems/ruby-2.0.0-rc1@rubygems_app:/home/rubygems_app/.rvm/gems/ruby-2.0.0-rc1@global"
  code        <<-EOF
    bundle install #--path .bundle
  EOF
end


#NOTE maybe not needed, add rvm bashrc config line
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

#NOTE add unicorn pid and error log
unicorn_config "/etc/unicorn/rubygems_app.rb" do
  listen({ node['unicorn']['port'] => node['unicorn']['options'] })
  working_directory ::File.join(node['rubygems_app']['name'], 'current')
  worker_timeout node['unicorn']['worker_timeout']
  preload_app node['unicorn']['preload_app']
  worker_processes node['unicorn']['worker_processes']
  before_fork node['unicorn']['before_fork']
end

rvm_shell "start unicorn" do
  ruby_string node['rubygems_app']['ruby_rvm_version']
  user        node['rubygems_app']['name']
  group       node['rubygems_app']['name']
  cwd         "#{node['rubygems_app']['application_path']}/current"
  #path        "home/rubygems_app/.rvm/gems/ruby-2.0.0-rc1@rubygems_app:/home/rubygems_app/.rvm/gems/ruby-2.0.0-rc1@global"
  #NOTE add path to config file with unicorn pid
  code        <<-EOF
    unicorn -D
  EOF
end


file "#{node['nginx']['dir']}/sites-available/#{node['rubygems']['domain']}" do
  owner node['name']
  mode  "0644"
end

template "/etc/nginx/sites-available/#{node['rubygems']['domain']}" do
    source "nginx_site.erb"
    mode 644
    variables(
      :application_name => node['rubygems_app']['domain'],
      :application_path => node['rubygems_app']['application_path'],
      :unicorn_port => node['unicorn']['port']
    )
  end

# enable your sites configuration using a definition from the nginx cookbook
nginx_site node['rubygems_app']['domain'] do
  enable true
end



# Copyright (C) 2014 Erich Kaderka
#
# All rights reserved - Do Not Redistribute
#
