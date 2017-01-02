require 'klarna/digest'

module Klarna
  module Methods
    module AddInvoice
      def self.xmlrpc_name
        'add_invoice'
      end

      def self.xmlrpc_params(store_id, store_secret, api_version, client_name, params)
        [
          params[:pno],
          params.fetch(:gender, ''),
          params.fetch(:reference, ''),
          params.fetch(:reference_code, ''),
          params.fetch(:order_id_1, ''),
          params.fetch(:order_id_2, ''),
          params[:delivery_address],
          params[:billing_address],
          params.fetch(:client_ip, ''),
          params[:flags],
          params[:currency],
          params[:country],
          params[:language],
          store_id,
          digest(params[:goods_list], store_secret),
          params[:pno_encoding],
          params[:pclass],
          params[:goods_list],
          params.fetch(:comment, ''),
          params.fetch(:shipment_info, []),
          params.fetch(:travel_info, []),
          params.fetch(:income_expense, []),
          params.fetch(:bank_info, []),
          params.fetch(:session_id, {}),
          params.fetch(:extra_info, [])
        ]
      end

      private

      def self.digest(goodslist, store_secret)
        goods_for_digest = goods_for_digest(goodslist)

        array = [*goods_for_digest, store_secret]
        Klarna::Digest.for(array)
      end

      def self.goods_for_digest(goodslist)
        [].tap do |array|
          goodslist.each do |goods|
            array.push goods[:goods][:title]
          end
        end
      end

    end
  end
end