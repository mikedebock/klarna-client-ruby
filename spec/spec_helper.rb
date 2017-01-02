require_relative '../lib/klarna'

require 'factory_girl'
FactoryGirl.find_definitions

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.color = true
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock

  c.filter_sensitive_data('<KLARNA_HOST>')  { ENV['KLARNA_HOST'] }
  c.filter_sensitive_data('<KLARNA_PORT>') { ENV['KLARNA_PORT'] }

  c.configure_rspec_metadata!
end

require 'support/configuration_helper'

require 'dotenv'
Dotenv.load
