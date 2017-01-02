module Klarna
  module ErrorHandling

    class RetryableError < StandardError; end

    class ErrorHandler
      def initialize(max_retries, method, *args)
        @max_retries = max_retries
        @method      = method
        @args        = args
      end

      def on_retry(retry_count)
        ErrorHandling.clear_ssl_errors
        yield
      rescue *IGNORED_ERRORS.map(&:klass) => e
        raise e unless retry_count < @max_retries
        ErrorHandling.tag(e).with(@method, @args).ignore_or_raise
      end
    end

    class IgnoredError
      attr_reader :klass, :allowed_values

      def initialize(klass:, message: //, allowed_values: {})
        @klass          = klass
        @message        = message
        @allowed_values = allowed_values
      end

      def matches?(error)
        @klass == error.class && error.message =~ @message && @allowed_values.all? { |sym, allowed_values_for_sym| allowed_values_for_sym.include? error.send(sym) }
      end
    end

    RETRYABLE_ERRORS = [::Errno::ECONNRESET, EOFError, Klarna::ErrorHandling::RetryableError]
    IGNORED_ERRORS   = [IgnoredError.new(klass: XMLRPC::FaultException, allowed_values: { faultCode: Klarna::Constants::TIMEOUT_FAULT_CODES }),
                        IgnoredError.new(klass: RuntimeError, message: /HTTP-Error: (500 Internal Server Error|503 Service Unavailable)/),
                        IgnoredError.new(klass: Net::OpenTimeout, message: /execution expired/)]

    def self.for(max_retries:, method:, args:)
      ErrorHandler.new(max_retries, method, args)
    end

    module ConceivablyIgnorable
      def with(method_name, method_params)
        self.tap do
          @method_name   = method_name
          @method_params = method_params
        end
      end

      def ignore_or_raise
        if ignore?
          Klarna.configuration.logger.warn(message: "An error occurred while calling Klarna XMLRPC. Retrying!",
                                           action: @method_name ? @method_name.camelize : nil,
                                           error: { type: self.class, message: message }.merge(additional_error_params),
                                           request_body: @method_params)

          raise RetryableError
        end
        raise self
      end

      private

      def ignore?
        matching_ignored_error != nil
      end

      def matching_ignored_error
        @matching_ignored_error ||= IGNORED_ERRORS.find { |ignored_error| ignored_error.matches?(self) }
      end

      def additional_error_params
        additional_params = matching_ignored_error.allowed_values.keys
        additional_params.empty? ? {} : Hash[additional_params.map { |sym| [sym, self.send(sym)] }]
      end
    end

    private

    def self.tag(e)
      class << e
        attr_accessor :method_name, :method_params
      end
      e.extend ConceivablyIgnorable
    end

    # This is due to a bug in ruby's OpenSSL implementation (See https://bugs.ruby-lang.org/issues/7215 for more details)
    def self.clear_ssl_errors
      unless OpenSSL.errors.empty?
        Klarna.configuration.logger.warn(message: "Clearing SSL errors",
                                         errors: OpenSSL.errors.join(', '))
        OpenSSL.errors.clear
      end
    end
  end
end
