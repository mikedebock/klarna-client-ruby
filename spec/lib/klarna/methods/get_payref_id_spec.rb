require 'spec_helper'

describe Klarna::Methods::GetPayrefId do

  describe '.xmlrpc_name' do
    it 'is get_payref_id' do
      expect(subject.xmlrpc_name).to eq('get_payref_id')
    end
  end

  describe '.xmlrpc_params' do

    let(:store_id)     { ENV['KLARNA_STORE_ID'] }
    let(:store_secret) { ENV['KLARNA_STORE_SECRET'] }
    let(:api_version)  { Klarna::Client::KLARNA_API_VERSION }
    let(:client_name)  { ENV['CLIENT_NAME'] }

    let(:method_params) do
      subject.xmlrpc_params(store_id, store_secret, api_version, client_name, {})
    end

    it 'returns an array of 2 elements' do
      expect(method_params.size).to eq(2)
    end

    it 'returns the store id in position 0' do
      expect(method_params[0]).to eq(store_id)
    end

    it 'returns the digest in position 1' do
      expect(method_params[1]).to be_a(String)
    end

  end

end
