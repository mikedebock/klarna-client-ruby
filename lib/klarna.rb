require 'klarna/version'
require 'klarna/client'
require 'klarna/configuration'
require 'klarna/connection'
require 'klarna/status_connection'
require 'klarna/constants'
require 'klarna/error_handling'
require 'klarna/fred_checker'

module Klarna
  def self.configure
    yield configuration if block_given?
  end

  def self.configuration
    @configuration ||= Klarna::Configuration.new
  end
end
