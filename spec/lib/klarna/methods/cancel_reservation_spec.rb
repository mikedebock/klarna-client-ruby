require 'spec_helper'

describe Klarna::Methods::CancelReservation do
  describe '.xmlrpc_name' do
    it 'is cancel_reservation' do
      expect(subject.xmlrpc_name).to eq('cancel_reservation')
    end
  end

  describe '.xmlrpc_params' do
    context 'given the following input parameters' do
      let(:params)       { { :rno => '30' } }

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

      it 'returns the RNO in position 0' do
        expect(method_params[0]).to eq('30')
      end

      it 'returns the store id in position 1' do
        expect(method_params[1]).to eq(store_id)
      end

      it 'returns the digest in position 2' do
        expect(method_params[2]).to be_a(String)
      end
    end
  end
end
