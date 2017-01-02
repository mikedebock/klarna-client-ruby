require 'logger'

module Klarna
  class Configuration
    attr_accessor :hostname, :port, :retries, :sleep, :store_id, :store_secret, :timeout, :client_name,
      :pool_size, :pool_timeout, :pool_warn_timeout, :pool_idle_timeout
    attr_writer :logger

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def retries
      @retries ||= 2
    end

    def sleep
      @sleep ||= 0.1
    end

    def timeout
      @timeout ||= 70
    end

    def client_name
      @client_name ||= 'ruby_client'
    end

    def pool_size
      @pool_size ||= 2
    end

    def pool_timeout
      @pool_timeout ||= 10
    end

    def pool_warn_timeout
      @pool_warn_timeout ||= 2
    end

    def pool_idle_timeout
      @pool_idle_timeout ||= 60
    end

    def use_instrumentation?
      @use_instrumentation == true
    end

    def use_instrumentation!
      require_relative './request_instrumentation'
      @use_instrumentation = true
    end
  end
end
