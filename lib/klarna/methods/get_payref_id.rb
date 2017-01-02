require 'klarna/digest'

module Klarna
  module Methods
    module GetPayrefId

      def self.xmlrpc_name
        'get_payref_id'
      end

      def self.xmlrpc_params(store_id, store_secret, api_version, client_name, params)
        [
          store_id,
          digest(store_id, store_secret)
        ]
      end

      private

      def self.digest(store_id, store_secret)
        array = [store_id, store_secret]
        Klarna::Digest.for(array)
      end
    end
  end
end
