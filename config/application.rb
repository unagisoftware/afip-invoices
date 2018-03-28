# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
# require "active_job/railtie"
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AfipInvoices
  class Application < Rails::Application
    config.load_defaults 6.1

    config.time_zone = 'Buenos Aires'
    config.api_only  = true

    config.autoload_paths += %W[#{config.root}/errors]
    config.autoload_paths += %W[#{config.root}/managers]
    config.autoload_paths += %W[#{config.root}/representers]
    config.autoload_paths += %W[#{config.root}/services]
    config.autoload_paths += %W[#{config.root}/uploaders]

    config.generators do |g|
      g.fixture_replacement :factory_bot, suffix_factory: 'factory'
      g.test_framework :rspec
    end
  end
end
