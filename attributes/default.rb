#name of the app, domain and path
default['rubygems_app']['name'] = 'rubygems_app'
default['rubygems_app']['domain'] = 'rubygems_app.com'
default['rubygems_app']['application_path'] =  "/home/#{default['rubygems_app']['name']}"
default['rubygems_app']['git_repository'] = 'https://github.com/erich/simple-rails.git'
default['rubygems_app']['bashrc'] = "#{default['rubygems_app']['application_path']}/.bashrc"
default['rubygems_app']['database_name'] = 'rubygems_app'
default['rubygems_app']['database_password'] = 'rubygems_app'
default['rubygems_app']['ruby_rvm_version'] = "ruby-2.0.0@#{default['rubygems_app']['name']}"


#unicorn configuration, port, worker processes
default['unicorn']['config_file'] =  "/etc/unicorn/#{default['rubygems_app']['name']}.rb"
default['unicorn']['worker_timeout'] = 60
default['unicorn']['preload_app'] = false
default['unicorn']['worker_processes'] = [node[:cpu][:total].to_i * 4, 8].min
default['unicorn']['preload_app'] = false
default['unicorn']['before_fork'] = 'sleep 1'
default['unicorn']['port'] = '8080'
default['unicorn']['options'] = { :tcp_nodelay => true, :backlog => 100 }
