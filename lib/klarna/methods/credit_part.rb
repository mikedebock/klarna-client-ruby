require 'klarna/digest'

module Klarna
  module Methods
    module CreditPart
      def self.xmlrpc_name
        'credit_part'
      end

      def self.xmlrpc_params(store_id, store_secret, api_version, client_name, params)
        [
          store_id,
          params[:invoice_number],
          params.fetch(:artnos, {}),
          params[:credno],
          digest(store_id, params[:invoice_number], params[:artnos], store_secret),
          params.fetch(:flags, 0),
          params[:goods_list]
        ]
      end

      private

      def self.digest(store_id, invoice_number, artnos, store_secret)
        artnos_for_digest = artnos_for_digest(artnos)
        array = [store_id, invoice_number, *artnos_for_digest, store_secret]

        Klarna::Digest.for(array)
      end

      def self.artnos_for_digest(artnos)
        [].tap do |articles|
          if artnos
            artnos.each do |article|
              articles.push article[:artno]
              articles.push article[:qty]
            end
          end
        end
      end
    end
  end
end
