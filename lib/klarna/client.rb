require 'klarna/methods/get_addresses'
require 'klarna/methods/reserve_amount'
require 'klarna/methods/activate'
require 'klarna/methods/credit_invoice'
require 'klarna/methods/cancel_reservation'
require 'klarna/methods/get_payref_id'
require 'klarna/methods/create_prepaid_order'
require 'klarna/methods/check_order_status'
require 'klarna/methods/credit_part'
require 'klarna/methods/add_invoice'
require 'klarna/methods/lookup_invoice'
require 'klarna/methods/order_info'
require 'klarna/methods/extend_invoice_due_date'

module Klarna
  class Client
    KLARNA_API_VERSION = '4.1'

    def initialize(options = {})
      @hostname     = options[:hostname]     || Klarna.configuration.hostname
      @port         = options[:port]         || Klarna.configuration.port
      @store_id     = options[:store_id]     || Klarna.configuration.store_id
      @store_secret = options[:store_secret] || Klarna.configuration.store_secret
      @retries      = options[:retries]      || Klarna.configuration.retries
      @sleep        = options[:sleep]        || Klarna.configuration.sleep
      @timeout      = options[:timeout]      || Klarna.configuration.timeout
      @client_name  = options[:client_name]  || Klarna.configuration.client_name
    end

    def get_addresses(params)
      call_method(Klarna::Methods::GetAddresses, params)
    end

    def self.get_addresses(params)
      new.get_addresses(params)
    end

    def reserve_amount(params)
      call_method(Klarna::Methods::ReserveAmount, params)
    end

    def self.reserve_amount(params)
      new.reserve_amount(params)
    end

    def activate(params)
      call_method(Klarna::Methods::Activate, params)
    end

    def self.activate(params)
      new.activate(params)
    end

    def credit_invoice(params)
      call_method(Klarna::Methods::CreditInvoice, params)
    end

    def self.credit_invoice(params)
      new.credit_invoice(params)
    end

    def cancel_reservation(params)
      call_method(Klarna::Methods::CancelReservation, params)
    end

    def self.cancel_reservation(params)
      new.cancel_reservation(params)
    end

    def get_payref_id
      call_method(Klarna::Methods::GetPayrefId, {})
    end

    def self.get_payref_id
      new.get_payref_id
    end

    def create_prepaid_order(params)
      call_method(Klarna::Methods::CreatePrepaidOrder, params)
    end

    def self.create_prepaid_order(params)
      new.create_prepaid_order(params)
    end

    def check_order_status(params)
      call_method(Klarna::Methods::CheckOrderStatus, params)
    end

    def self.check_order_status(params)
      new.check_order_status(params)
    end

    def credit_part(params)
      call_method(Klarna::Methods::CreditPart, params)
    end

    def self.credit_part(params)
      new.credit_part(params)
    end

    def add_invoice(params)
      call_method(Klarna::Methods::AddInvoice, params)
    end

    def self.add_invoice(params)
      new.add_invoice(params)
    end

    def self.lookup_invoice(params)
      new.lookup_invoice(params)
    end

    def lookup_invoice(params)
      call_method(Klarna::Methods::LookupInvoice, params)
    end

    def self.order_info(params)
      new.order_info(params)
    end

    def order_info(params)
      call_method(Klarna::Methods::OrderInfo, params)
    end

    def extend_invoice_due_date(params)
      call_method(Klarna::Methods::ExtendInvoiceDueDate, params)
    end

    def self.extend_invoice_due_date(params)
      new.extend_invoice_due_date(params)
    end

    def self.ping
      response = status_connection.get
      [response.success?, nil]
    rescue StandardError => e
      [false, e]
    end

    private

    def call_method(method, params)
      if Klarna.configuration.use_instrumentation?
        Klarna::RequestInstrumentation.instrument(method, instrumentation_params.merge(params)) do
          xml_rpccall(method, params)
        end
      else
        xml_rpccall(method,params)
      end
    end

    def xml_rpccall(method, params)
      xmlrpc_params = method.xmlrpc_params(@store_id, @store_secret, KLARNA_API_VERSION, @client_name, params)

      connection.call(method.xmlrpc_name, params, KLARNA_API_VERSION, @client_name, *xmlrpc_params)
    end

    def connection
      @connection ||= Klarna::Connection.new(@hostname, @port, @retries, @sleep, @timeout)
    end

    def instrumentation_params
      {
        estore_id:   @store_id,
        client_name: @client_name
      }
    end

    def self.status_connection
      StatusConnection.build
    end
  end
end
