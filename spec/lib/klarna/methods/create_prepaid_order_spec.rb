require 'spec_helper'

describe Klarna::Methods::CreatePrepaidOrder do

  describe '.xmlrpc_name' do
    it 'is create_prepaid_order' do
      expect(subject.xmlrpc_name).to eq('create_prepaid_order')
    end
  end

  describe '.xmlrpc_params' do
    let(:params) do
      {
        :country            => 209,
        :language           => 138,
        :currency           => 0,
        :goods_list         => goods_list,
        :payment_info       => payment_info,
        :customer_info      => customer_info,
        :merchant_reference => merchant_reference
      }
    end

    let(:goods_list) do
      [
        {
          :goods => {
            :artno    => 'article#',
            :title    => 'Article Foo',
            :price    => 199,
            :vat      => 25,
            :discount => 0,
            :flags    => 32
          },
          :qty => 1
        }
      ]
    end

    let(:payment_info) do
      {
        :external_payref_id => "EXT_ID_1234567",
        :payref_id          => "test8eIfQx8TjiYbdyWiDA"
      }
    end

    let(:customer_info) do
      {
        :cellno => "+46700029099",
        :contact => {}
      }
    end

    let(:merchant_reference) do
      {
        :order_id_1 => 'FirstId',
        :order_id_2 => 'SecondId'
      }
    end

    let(:store_id)     { ENV['KLARNA_STORE_ID'] }
    let(:store_secret) { ENV['KLARNA_STORE_SECRET'] }
    let(:api_version)  { Klarna::Client::KLARNA_API_VERSION }
    let(:client_name)  { ENV['CLIENT_NAME'] }

    let(:method_params) do
      subject.xmlrpc_params(store_id, store_secret, api_version, client_name, params)
    end

    it 'returns an array of 9 elements' do
      expect(method_params.size).to eq(9)
    end

    it 'returns the store id in position 0' do
      expect(method_params[0]).to eq(store_id)
    end

    it 'returns the digest in position 1' do
      expect(method_params[1]).to be_a(String)
    end

    it 'returns the country in position 2' do
      expect(method_params[2]).to eq(209)
    end

    it 'returns the language in position 3' do
      expect(method_params[3]).to eq(138)
    end

    it 'returns the currency in position 4' do
      expect(method_params[4]).to eq(0)
    end

    it 'returns the good_list in position 5' do
      expect(method_params[5]).to eq(goods_list)
    end

    it 'returns the payment_info in position 6' do
      expect(method_params[6]).to eq(payment_info)
    end

    it 'returns the customer_details in position 7' do
      expect(method_params[7]).to eq(customer_info)
    end

    context 'when merchant_reference is sent' do
      it 'returns the merchant_reference in position 8' do
        expect(method_params[8]).to eq(merchant_reference)
      end
    end

    context 'when merchant_reference is not send' do
      before do
        params.except!(:merchant_reference)
      end

      it 'returns the default merchant_reference in position 8' do
        expect(method_params[8]).to eq({ :order_id_1 => '', :order_id_2 => ''})
      end
    end
  end
end
