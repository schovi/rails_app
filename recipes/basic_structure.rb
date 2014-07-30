shared_path  = "#{node.rails_app[:application_path]}/shared"
current_path = "#{node.rails_app[:application_path]}/current"

user_account node['rails_app']['name'] do
  action :create
end

#tmux :: Helps with debugging
#FIXME add tmux config with key set to C-A
#libv8 :: Fix Could not find a JavaScript runtime. See https://github.com/sstephenson/execjs for a list of available runtimes. (ExecJS::RuntimeUnavailable) on Debian - starting rails app
#libmysqlclient :: Install development headers for mysql required by mysql2 gem
%w{git tmux libv8-dev libmysqlclient-dev}.each do |pkg|
  package pkg do
    action :install
  end
end

#create directory for pids
directory "/tmp/pids" do
  owner "root"
  group "root"
  mode 00777
  action :create
end

application node['rails_app']['name'] do
  owner      node['rails_app']['name']
  group      node['rails_app']['name']
  path       node['rails_app']['application_path']
  repository node['rails_app']['git_repository']
  revision   node['rails_app']['git_revision']

  create_dirs_before_symlink ["log", "tmp"]

  _database = node['rails_app']['database']
  _database_username = node['rails_app']['database_username']
  _database_password = node['rails_app']['database_password']

  rails do
    database do
      adapter  'mysql2'
      database _database
      username _database_username
      password _database_password
    end
  end
end

# Configuration
template "#{shared_path}/configuration.yml" do
  source "configuration.yml.erb"
  owner node.rails_app[:name] and group node.rails_app[:name] and mode 0755
  action :create
end

link "#{current_path}/config/configuration.yml" do
  to "#{shared_path}/configuration.yml"
  owner node.rails_app[:name] and group node.rails_app[:name] and mode 0755
end

# Configuration ruby + gemset
template "#{shared_path}/.ruby-gemset" do
  source "ruby-gemset.erb"
  owner node.rails_app[:name] and group node.rails_app[:name] and mode 0755
  action :create
end

file "#{current_path}/.ruby-gemset" do
  action :delete
end

link "#{current_path}/.ruby-gemset" do
  to "#{shared_path}/.ruby-gemset"
  owner node.rails_app[:name] and group node.rails_app[:name] and mode 0755
end

# Configuration ruby + gemset
template "#{shared_path}/.ruby-version" do
  source "ruby-version.erb"
  owner node.rails_app[:name] and group node.rails_app[:name] and mode 0755
  action :create
end

file "#{current_path}/.ruby-version" do
  action :delete
end

link "#{current_path}/.ruby-version" do
  to "#{shared_path}/.ruby-version"
  owner node.rails_app[:name] and group node.rails_app[:name] and mode 0755
end