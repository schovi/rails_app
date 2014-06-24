name             'rubygems_app'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures rubygems_app'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'user'
depends 'application_ruby'
depends 'rvm'
depends 'nginx'
depends 'unicorn'
