require 'spec_helper'

describe Klarna::Methods::GetAddresses do
  describe '.xmlrpc_name' do
    it 'is get_addresses' do
      expect(subject.xmlrpc_name).to eq('get_addresses')
    end
  end

  describe '.xmlrpc_params' do

    let(:store_id)     { ENV['KLARNA_STORE_ID'] }
    let(:store_secret) { ENV['KLARNA_STORE_SECRET'] }
    let(:api_version)  { Klarna::Client::KLARNA_API_VERSION }
    let(:client_name)  { ENV['CLIENT_NAME'] }

    let(:method_params) do
      subject.xmlrpc_params(store_id, store_secret, api_version, client_name, params)
    end

    context 'given input parameters with a PNO' do
      let(:params) do
        {
          :pno          => '410321-9202',
          :pno_encoding => Klarna::Constants::GET_ADDRESSES_PNO_ENCODING_SE,
          :type         => Klarna::Constants::GET_ADDRESSES_TYPE_PNO
        }
      end

      it 'returns an array of 6 elements' do
        expect(method_params.size).to eq(6)
      end

      it 'returns the PNO in position 0' do
        expect(method_params[0]).to eq('410321-9202')
      end

      it 'returns the store id in position 1' do
        expect(method_params[1]).to eq(store_id)
      end

      it 'returns the digest in position 2' do
        expect(method_params[2]).to be_a(String)
      end

      it 'returns the pno encoding in position 3' do
        expect(method_params[3]).to eq(2)
      end

      it 'returns the type in position 4' do
        expect(method_params[4]).to eq(5)
      end

      it 'returns the client ip in position 5' do
        expect(method_params[5]).to be_empty
      end
    end

    context 'given input parameters with a TNO' do
      let(:params) do
        {
          :tno          => '46704455668',
          :pno_encoding => Klarna::Constants::GET_ADDRESSES_PNO_ENCODING_SE,
          :type         => Klarna::Constants::GET_ADDRESSES_TYPE_TNO
        }
      end

      it 'returns an array of 6 elements' do
        expect(method_params.size).to eq(6)
      end

      it 'returns the TNO in position 0' do
        expect(method_params[0]).to eq('46704455668')
      end

      it 'returns the store id in position 1' do
        expect(method_params[1]).to eq(store_id)
      end

      it 'returns the digest in position 2' do
        expect(method_params[2]).to be_a(String)
      end

      it 'returns the pno encoding in position 3' do
        expect(method_params[3]).to eq(2)
      end

      it 'returns the type in position 4' do
        expect(method_params[4]).to eq(6)
      end

      it 'returns the client ip in position 5' do
        expect(method_params[5]).to be_empty
      end
    end
  end

end
