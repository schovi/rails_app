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
