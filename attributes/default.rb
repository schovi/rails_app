#name of the app, domain and path
default['name'] = 'rubygems_app'
default['domain'] = 'rubygems_app.com'
default['application_path'] =  '/home/rubygems_app'
default['bashrc'] = "#{default['rubygems_app']['application_path']}/.bashrc"


#unicorn configuration, port, worker processes
default['unicorn']['config_file'] =  '/etc/unicorn/rubygems_app.rb'
default[:unicorn][:worker_timeout] = 60
default[:unicorn][:preload_app] = false
default[:unicorn][:worker_processes] = [node[:cpu][:total].to_i * 4, 8].min
default[:unicorn][:preload_app] = false
default[:unicorn][:before_fork] = 'sleep 1'
default[:unicorn][:port] = '8080'
default[:unicorn][:options] = { :tcp_nodelay => true, :backlog => 100 }
