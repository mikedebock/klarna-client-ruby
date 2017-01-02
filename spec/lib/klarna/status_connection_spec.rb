require 'spec_helper'

module Klarna
  describe StatusConnection do
    describe '.build' do
      let(:hostname) { "smooo.th"}
      let(:port)     { "123"}

      before do
        allow(Klarna.configuration).to receive(:hostname).and_return(hostname)
        allow(Klarna.configuration).to receive(:port).and_return(port)
      end

      it 'builds a Faraday connection' do
        connection = StatusConnection.build

        expect(connection).to be_instance_of(Faraday::Connection)
      end

      it 'builds a connection with the configured hostname' do
        connection = StatusConnection.build

        expect(connection.url_prefix.host).to eq(hostname)
      end

      it 'builds a connection with the configured port' do
        connection = StatusConnection.build

        expect(connection.url_prefix.port).to eq(port.to_i)
      end

      it 'builds a connection with the status path' do
        connection = StatusConnection.build

        expect(connection.url_prefix.path).to eq('/version')
      end

      context 'when the client is not configured with port 443' do
        it 'builds a connection with the http scheme' do
          connection = StatusConnection.build

          expect(connection.url_prefix.scheme).to eq('http')
        end

        it 'builds a connection without ssl' do
          connection = StatusConnection.build

          expect(connection.ssl[:verify]).to be false
        end
      end

      context 'when the client is configured with port 443' do
        let(:port) { "443" }

        it 'builds a connection with the https scheme' do
          connection = StatusConnection.build

          expect(connection.url_prefix.scheme).to eq('https')
        end

        it 'builds a connection with ssl' do
          connection = StatusConnection.build

          expect(connection.ssl[:verify]).to be true
        end
      end
    end
  end
end