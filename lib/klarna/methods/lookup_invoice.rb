require 'klarna/digest'

module Klarna
  module Methods
    module LookupInvoice
      def self.xmlrpc_name
        'lookup_invoice'
      end

      def self.xmlrpc_params(store_id, store_secret, api_version, client_name, params)
        [
            store_id,
            params[:orderno],
            digest(store_id, params[:orderno], store_secret),
        ]
      end

      private

      def self.digest(store_id, orderno, store_secret)
        array = [store_id, orderno, store_secret]
        Klarna::Digest.for(array)
      end

    end
  end
end