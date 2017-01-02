require 'gene_pool'
require 'monitor'
require 'retryable'
require 'xmlrpc/client'

module Klarna
  class Connection
    extend MonitorMixin

    @@connection_pools = {}

    def initialize(xmlrpc_hostname, xmlrpc_port, retries, sleep, timeout)
      @xmlrpc_hostname = xmlrpc_hostname
      @xmlrpc_port     = xmlrpc_port.to_i
      @retries         = retries.to_i
      @sleep           = sleep.to_f
      @timeout         = timeout
      @pool            = get_connection_pool
    end

    def call(method, original_params, *args)
      error_handler = Klarna::ErrorHandling.for(max_retries: @retries, method: method, args: args)

      Retryable.retryable(tries: @retries + 1, on: Klarna::ErrorHandling::RETRYABLE_ERRORS, sleep: @sleep) do |retry_count|
        Klarna.configuration.logger.info(type: 'Request',
                                         action: method.camelize,
                                         attempt: retry_count+1,
                                         request_body: original_params,
                                         xmlrpc_params: args)
        error_handler.on_retry(retry_count) do
          @pool.with_connection_auto_remove do |client|
            client.call(method, *args)
          end
        end
      end
    end

    private

    def get_connection_pool
      key = "#{@xmlrpc_hostname}:#{@xmlrpc_port}:#{@timeout}"
      self.class.synchronize do
        config = pool_settings(key)
        @@connection_pools[key] ||= GenePool.new(config) do
          xmlrpc_client.tap do |client|
            client.http_header_extra = headers
            client.http.keep_alive_timeout = config[:idle_timeout]
          end
        end
      end
    end

    def pool_settings(key)
      {
        :name         => "KlarnaConnection-#{key}",
        :pool_size    => Klarna.configuration.pool_size,
        :timeout      => Klarna.configuration.pool_timeout,
        :warn_timeout => Klarna.configuration.pool_warn_timeout,
        :idle_timeout => Klarna.configuration.pool_idle_timeout,
        :logger       => Klarna.configuration.logger,
        :close_proc   => lambda {|connection| connection.http.finish}
      }
    end

    def xmlrpc_client
      XMLRPC::Client.new_from_hash({
        :host    => @xmlrpc_hostname,
        :path    => '/',
        :port    => @xmlrpc_port,
        :use_ssl => use_ssl?,
        :timeout => @timeout
      })
    end

    def use_ssl?
      @xmlrpc_port == 443
    end

    def headers
      {
        'Accept-Encoding' => 'deflate,gzclient_ip',
        'Content-Type'    => 'text/xml;charset=utf-8',
        'Accept-Charset'  => 'utf-8',
        'Connection'      => 'keep-alive',
        'User-Agent'      => 'ruby/xmlrpc'
      }
    end
  end
end
