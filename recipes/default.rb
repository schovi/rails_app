#
# Cookbook Name:: rails_app
# Recipe:: default
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#

include_recipe "nginx"



rvm_shell "bundle" do
  ruby_string node['rails_app']['ruby_rvm_version']
  user        node['rails_app']['name']
  group       node['rails_app']['name']
  cwd         "#{node['rails_app']['application_path']}/current"
  #path        "home/rails_app/.rvm/gems/ruby-2.0.0-rc1@rails_app:/home/rails_app/.rvm/gems/ruby-2.0.0-rc1@global"
  code        <<-EOF
    bundle install #--path .bundle
  EOF
end


#NOTE maybe not needed, add rvm bashrc config line
rvm_line = '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"'
ruby_block "add rvm basrhc config line" do
  block do
    #NOTE move this to attributes
    file = Chef::Util::FileEdit.new("/home/#{node['rails_app']['name']}/.bashrc")
    file.insert_line_if_no_match(rvm_line, rvm_line)
    file.write_file
  end
end

#NOTE it raises weird debian syntax error on line 6
#ruby_block "reload .bashrc" do
#  block do
#    Chef::Config.from_file("/home/rails_app/.bashrc")
#  end
#end

#NOTE add unicorn pid and error log
#NOTE dynamic attribute instead of hardcoded string
unicorn_config "/etc/unicorn/rails_app.rb" do
  listen({ node['unicorn']['ports'] => node['unicorn']['options'] })
  working_directory ::File.join(node['rails_app']['name'], 'current')
  worker_timeout node['unicorn']['worker_timeout']
  preload_app node['unicorn']['preload_app']
  worker_processes node['unicorn']['worker_processes']
  before_fork node['unicorn']['before_fork']
  pid node['rails_app']['unicorn_pid']
end

rvm_shell "start unicorn" do
  ruby_string node['rails_app']['ruby_rvm_version']
  user        node['rails_app']['name']
  group       node['rails_app']['name']
  cwd         "#{node['rails_app']['application_path']}/current"
  #path        "home/rails_app/.rvm/gems/ruby-2.0.0-rc1@rails_app:/home/rails_app/.rvm/gems/ruby-2.0.0-rc1@global"
  #NOTE add path to config file with unicorn pid
  code        <<-EOF
    unicorn -D "/etc/#{node['rails_app']['name']}.rb"
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
      :unicorn_ports => node['unicorn']['ports']
    )
  end

# enable your sites configuration using a definition from the nginx cookbook
nginx_site node['rails_app']['domain'] do
  enable true
end



# Copyright (C) 2014 Erich Kaderka
#
# All rights reserved - Do Not Redistribute
#
