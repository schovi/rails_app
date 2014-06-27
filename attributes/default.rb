#name of the app, domain and path
default['rails_app']['name'] = 'rails_app'
default['rails_app']['domain'] = 'rails_app.com'
default['rails_app']['application_path'] =  "/home/#{default['rails_app']['name']}"
default['rails_app']['git_repository'] = 'https://github.com/erich/simple-rails.git'
default['rails_app']['bashrc'] = "#{default['rails_app']['application_path']}/.bashrc"
default['rails_app']['database_name'] = 'rails_app'
default['rails_app']['database_password'] = 'rails_app'
default['rails_app']['ruby_rvm_version'] = "ruby-2.0.0@#{default['rails_app']['name']}"


#unicorn configuration, port, worker processes
default['unicorn']['config_file'] =  "/etc/unicorn/#{default['rails_app']['name']}.rb"
default['unicorn']['worker_timeout'] = 60
default['unicorn']['preload_app'] = false
default['unicorn']['worker_processes'] = [node[:cpu][:total].to_i * 4, 8].min
default['unicorn']['preload_app'] = false
default['unicorn']['before_fork'] = 'sleep 1'
default['unicorn']['port'] = '8080'
default['unicorn']['options'] = { :tcp_nodelay => true, :backlog => 100 }
