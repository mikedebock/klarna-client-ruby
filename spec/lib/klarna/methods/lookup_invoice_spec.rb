require 'spec_helper'

describe Klarna::Methods::LookupInvoice do
  describe '.xmlrpc_name' do
    it 'is lookup_invoice' do
      expect(subject.xmlrpc_name).to eq('lookup_invoice')
    end

    describe '.xmlrpc_params' do
      context 'given the following input parameters' do
        let(:orderno) { 'order1234' }
        let(:params) do
          {
              orderno: orderno,
          }
        end

        let(:store_id)     { ENV['KLARNA_STORE_ID'] }
        let(:store_secret) { ENV['KLARNA_STORE_SECRET'] }
        let(:api_version)  { Klarna::Client::KLARNA_API_VERSION }
        let(:client_name)  { ENV['CLIENT_NAME'] }

        let(:method_params) do
          subject.xmlrpc_params(store_id, store_secret, api_version, client_name, params)
        end

        it 'returns an array of 3 elements' do
          expect(method_params.size).to eq(3)
        end

        it 'returns the store id in position 0' do
          expect(method_params[0]).to eq(store_id)
        end

        it 'returns the order number in position 1' do
          expect(method_params[1]).to eq(orderno)
        end

        it 'returns the digest in position 2' do
          expect(method_params[2]).to be_a(String)
        end

      end
    end
  end
end