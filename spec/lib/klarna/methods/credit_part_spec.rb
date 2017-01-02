require 'spec_helper'

describe Klarna::Methods::CreditPart do
  describe '.xmlrpc_name' do
    it 'is credit_part' do
      expect(subject.xmlrpc_name).to eq('credit_part')
    end
  end

  describe '.xmlrpc_params' do
    context 'given the following input parameters' do
      let(:invoice_number) { '21312106990549275' }
      let(:params) do
        {
          :invoice_number   => invoice_number,
          :credno           => '',
          :flags            => Klarna::Constants::TEST_PERSON_FLAG,
          :goods_list       => goods_list,
        }
      end

      let(:goods_list) do
        [
          {
            :goods => {
              :artno    => 'HA',
              :title    => '2013-12-20 10:07 46736471584',
              :price    => 199,
              :vat      => 25,
              :discount => 0,
              :flags    => 32
            },
            :qty => 1
          }
        ]
      end

      let(:store_id)     { ENV['KLARNA_STORE_ID'] }
      let(:store_secret) { ENV['KLARNA_STORE_SECRET'] }
      let(:api_version)  { Klarna::Client::KLARNA_API_VERSION }
      let(:client_name)  { ENV['CLIENT_NAME'] }

      let(:method_params) do
        subject.xmlrpc_params(store_id, store_secret, api_version, client_name, params)
      end

      it 'returns an array of 7 elements' do
        expect(method_params.size).to eq(7)
      end

      it 'returns the store id in position 0' do
        expect(method_params[0]).to eq(store_id)
      end

      it 'returns the invoice number in position 1' do
        expect(method_params[1]).to eq(invoice_number)
      end

      it 'returns the article numbers in position 2' do
        expect(method_params[2]).to eq({})
      end

      it 'returns the credit number in position 3' do
        expect(method_params[3]).to eq('')
      end

      it 'returns the digest in position 4' do
        expect(method_params[4]).to be_a(String)
      end

      it 'returns the flags in position 5' do
        expect(method_params[5]).to eq(2)
      end

      it 'returns the goods list in position 6' do
        expect(method_params[6]).to eq(goods_list)
      end
    end
  end
end
