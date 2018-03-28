require 'rspec/rails'
require 'should_not/rspec'
require 'shoulda/matchers'
require 'webmock/rspec'
require 'simplecov'

SimpleCov.start 'rails' do
  add_filter '/app/uploaders/'
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include FactoryBot::Syntax::Methods

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
end

RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec::Matchers.define :match_valid_format do |format|
  match do |hash|
    expect(hash.size).to eq(format.size)

    hash.each do |key, value|
      klasses = Array(format[key])
      expect(format).to include(key)
      expect(klasses.any? { |klass| value.is_a?(klass) }).to be(true)
    end
  end
end

RSpec::Matchers.define :match_valid_representer_format do |format|
  match do |object|
    format.each do |key, value|
      klasses = Array(value)
      expect(object).to respond_to(key)
      expect(klasses.any? { |klass| object.send(key).is_a?(klass) }).to be(true)
    end
  end
end

FactoryBot::SyntaxRunner.class_eval do
  include RSpec::Mocks::ExampleMethods
end
