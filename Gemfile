# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.7.4'

gem 'carrierwave', '~> 2.0'
gem 'figaro'
gem 'multi_json'
gem 'pg'
gem 'prawn'
gem 'prawn-qrcode', '~> 0.5.2'
gem 'prawn-table'
gem 'puma'
gem 'rails', '~> 6.1.4.1'
gem 'redis'
gem 'representable'
gem 'savon'

group :development, :test do
  gem 'pry'
end

group :development do
  gem 'listen'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'shoulda-matchers', '4.0.0.rc1'
  gem 'should_not'
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
  gem 'webmock'
end

group :production do
  gem 'capistrano', require: false
  gem 'capistrano3-puma', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rbenv', require: false
  gem 'capistrano-systemd'
  gem 'rack-cache', require: 'rack/cache'
end
