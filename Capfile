# frozen_string_literal: true

require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/bundler'
require 'capistrano/rails/migrations'
require 'capistrano/rbenv'
require 'capistrano/puma'
require 'figaro'

install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Systemd

Figaro.application = Figaro::Application.new(
  path: File.expand_path('config/application.yml', __dir__),
)

Figaro.load

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
