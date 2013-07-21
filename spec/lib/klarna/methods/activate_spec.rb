require 'spec_helper'

describe Klarna::Methods::Activate do
  describe '#xmlrpc_name' do
    it 'is activate' do
      expect(subject.xmlrpc_name).to eq('activate')
    end
  end

  describe '#xmlrpc_params' do
    context 'given the following input parameters' do
      let(:params)       { {:rno => '123456'} }

      let(:store_id)     { ENV['KLARNA_STORE_ID'] }
      let(:store_secret) { ENV['KLARNA_STORE_SECRET'] }
      let(:api_version)  { Klarna::Client::KLARNA_API_VERSION }
      let(:client_name)  { Klarna::Client::CLIENT_NAME }

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

      it 'returns the RNO in position 2' do
        expect(method_params[2]).to eq('123456')
      end

      it 'returns the optional info in position 3' do
        expect(method_params[3]).to eq({})
      end

    end
  end
end
