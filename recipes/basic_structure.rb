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
  rails do
    #FIXME it should take attributes, not hardcoded strings
    database do
      database node['rails_app']['database']['database']
      username node['rails_app']['database']['username']
      password node['rails_app']['database']['password']
    end
  end
end
