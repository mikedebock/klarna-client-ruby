require 'klarna/digest'

module Klarna
  module Methods
    module OrderInfo
      def self.xmlrpc_name
        'order_info'
      end

      def self.xmlrpc_params(store_id, store_secret, api_version, client_name, params)
        [
            store_id,
            params[:invno],
            digest(store_id, params[:invno], store_secret),
        ]
      end

      private

      def self.digest(store_id, invno, store_secret)
        array = [store_id, invno, store_secret]
        Klarna::Digest.for(array)
      end

    end
  end
end