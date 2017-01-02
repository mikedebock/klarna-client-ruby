require 'klarna/digest'

module Klarna
  module Methods
    module CheckOrderStatus
      def self.xmlrpc_name
        'check_order_status'
      end

      def self.xmlrpc_params(store_id, store_secret, api_version, client_name, params)
        [
            store_id,
            digest(store_id, params[:id], store_secret),
            params[:id],
            params[:type]
        ]
      end

      private

      def self.digest(store_id, id, store_secret)
        array = [store_id, id, store_secret]
        Klarna::Digest.for(array)
      end

    end
  end
end
