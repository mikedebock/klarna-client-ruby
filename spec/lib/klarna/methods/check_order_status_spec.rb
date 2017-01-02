require 'spec_helper'

describe Klarna::Methods::CheckOrderStatus do
  describe '.xmlrpc_name' do
    it 'is check_order_status' do
      expect(subject.xmlrpc_name).to eq('check_order_status')
    end
  end

  describe '.xmlrpc_params' do
    context 'given the following input parameters' do
      let(:params) do
        {
          :id   => '40',
          :type => 0,
        }
      end

      let(:store_id)     { ENV['KLARNA_STORE_ID'] }
      let(:store_secret) { ENV['KLARNA_STORE_SECRET'] }
      let(:api_version)  { Klarna::Client::KLARNA_API_VERSION }
      let(:client_name)  { ENV['CLIENT_NAME'] }

      let(:method_params) do
        subject.xmlrpc_params(store_id, store_secret, api_version, client_name, params)
      end

      it 'returns an array of 4 elements' do
        expect(method_params.size).to eq(4)
      end

      it 'returns the store id in position 0' do
        expect(method_params[0]).to eq(store_id)
      end

      it 'returns the digest in position 1' do
        expect(method_params[1]).to be_a(String)
      end

      it 'returns the id in position 2' do
        expect(method_params[2]).to eq('40')
      end

      it 'returns the type in position 3' do
        expect(method_params[3]).to eq(0)
      end
    end
  end
end
