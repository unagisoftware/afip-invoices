ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'
require 'spec_helper'
require 'rails/test_help'
require 'mocks/afip_mock'
require 'mocks/invoices_service_mock'
require 'mocks/people_service_mock.rb'

if Rails.env.production?
  abort('The Rails environment is running in production mode!')
end

ActiveRecord::Migration.maintain_test_schema!
