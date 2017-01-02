require 'klarna/digest'

module Klarna
  module Methods
    module CreatePrepaidOrder

      def self.xmlrpc_name
        'create_prepaid_order'
      end

      def self.xmlrpc_params(store_id, store_secret, api_version, client_name, params)
        [
          store_id,
          digest(store_id, params[:payment_info], store_secret),
          params[:country],
          params[:language],
          params[:currency],
          params[:goods_list],
          params[:payment_info],
          params[:customer_info],
          params.fetch(:merchant_reference, { :order_id_1 => '', :order_id_2 => ''})
        ]

      end

      private

      def self.digest(store_id, payment_info, store_secret)
        array = [store_id, payment_info[:payref_id], payment_info[:external_payref_id], store_secret]
        Klarna::Digest.for(array)
      end
    end
  end
end
