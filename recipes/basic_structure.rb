user_account node['rubygems_app']['name'] do
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

application node['rubygems_app']['name'] do
  owner node['rubygems_app']['name']
  group node['rubygems_app']['name']
  path node['rubygems_app']['application_path']
  repository node['rubygems_app']['git_repository']
  revision 'master'
  rails do
    database do
      database "rubygems_app_production"
      username "rubygems_app"
      password "12*asda!BanqV"
    end
  end
end
