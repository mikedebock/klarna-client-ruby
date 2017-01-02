require 'faraday_middleware'
require 'klarna_correlation_id'

module Klarna
  class StatusConnection
    def self.build
      Faraday.new(status_url, ping_options) do |conn|
        conn.request :json
        conn.request :klarna_correlation_id_header
        conn.response :xml, :content_type => /\bxml$/
        conn.response :logger, Klarna.configuration.logger if Klarna.configuration.logger
        conn.use :instrumentation, name: 'request.klarna_client' if Klarna.configuration.use_instrumentation?
        conn.adapter Faraday.default_adapter
      end
    end

    private

    def self.ping_options
      {
        headers: {
          'Content-Type' => 'text/plain',
          'Accept'       => '*'
        },
        ssl: { verify: verify_ssl? },
        request: { timeout: Klarna.configuration.timeout }
      }
    end

    def self.status_url
      scheme = verify_ssl? ? 'https' : 'http'
      "#{scheme}://#{Klarna.configuration.hostname}:#{Klarna.configuration.port}/version"
    end

    def self.verify_ssl?
      Klarna.configuration.port.to_i == 443
    end
  end
end
