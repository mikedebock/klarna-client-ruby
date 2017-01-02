require 'active_support'

module Klarna
  module RequestInstrumentation
    # Adds ActiveSupport notification support to allow you to subscribe to these messages and print
    # more customized log messages
    #
    # Examples
    #
    #   ActiveSupport::Notifications.subscribe('request.klarna_client') do |name, starts, ends, _, data|
    #     xml_rpc_method = data[:method].xmlrpc_name
    #     xml_rpc_params = data[:params]
    #     duration = ends - starts
    #     # Your log message
    #   end
    def self.instrument(method, params)
      data = {
        method: method,
        params: params
      }

      ActiveSupport::Notifications.instrument('request.klarna_client', data) do
        begin
          data[:response_values] = yield
        rescue XMLRPC::FaultException => exception
          # Note with ActiveSupport 5.0 this is not needed, as the whole exception object is added by default to the data:
          # http://api.rubyonrails.org/v5.0.0.1/classes/ActiveSupport/Notifications/Instrumenter.html#method-i-instrument
          data[:xmlrpc_fault_code] = exception.faultCode
          raise exception
        end
      end
    end
  end
end