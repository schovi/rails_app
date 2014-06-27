user_account node['rails_app']['name'] do
  action :create
end

package 'git' do
  action :install
end

#it helps with debugging
#NOTE add tmux config with key set to C-A
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

application node['rails_app']['name'] do
  owner node['rails_app']['name']
  group node['rails_app']['name']
  path node['rails_app']['application_path']
  repository node['rails_app']['git_repository']
  revision 'master'
  rails do
    database do
      database node['rails_app']['database_name']
      username node['rails_app']['name']
      password node['rails_app']['database_password']
    end
  end
end
