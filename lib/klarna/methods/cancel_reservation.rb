require 'klarna/digest'

module Klarna
  module Methods
    module CancelReservation
      def self.xmlrpc_name
        'cancel_reservation'
      end

      def self.xmlrpc_params(store_id, store_secret, api_version, client_name, params)
        [
            params[:rno],
            store_id,
            digest(store_id, params[:rno], store_secret)
        ]
      end

      private

      def self.digest(store_id, rno, store_secret)
        array = [store_id, rno, store_secret]
        Klarna::Digest.for(array)
      end

    end
  end
end
