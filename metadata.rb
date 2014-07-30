name             'rails_app'
maintainer       '6artasians'
maintainer_email 'erich.kaderka@gmail.com'
license          'All rights reserved'
description      'Installs/Configures rails_app'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'

depends 'user'
depends 'application'
depends 'application_ruby'
depends 'rvm'
depends 'nginx'
depends 'unicorn'
