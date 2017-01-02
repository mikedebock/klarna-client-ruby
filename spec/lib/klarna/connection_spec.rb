require 'spec_helper'

describe Klarna::Connection do
  describe "pool" do
    subject(:connection) { build(:connection) }

    before do
      Klarna::Connection.class_variable_get("@@connection_pools").each_value do |pool|
        pool.pool_size = 0 # kills all client objects
        pool.pool_size = Klarna.configuration.pool_size # makes it so that new clients can be created in the pool
      end
    end

    it 'creates only a single, pooled, XMLRPC::Client instance' do
      allow_any_instance_of(::XMLRPC::Client).to receive(:call)
      expect(::XMLRPC::Client).to receive(:new_from_hash).and_call_original.once

      connection.call('endpoint', 'arg1', 'arg2')
      connection.call('endpoint', 'arg1', 'arg2')
    end

    it 'creates two pools if params to XMLRPC::Client differ' do
      allow_any_instance_of(::XMLRPC::Client).to receive(:call)
      expect(::XMLRPC::Client).to receive(:new_from_hash).and_call_original.twice

      connection.call('endpoint', 'arg1', 'arg2')
      build(:connection, xmlrpc_hostname: 'otherhost.com').call('endpoint', 'arg1', 'arg2')
    end
  end

  describe '#call' do
    let(:client)  { instance_double(::XMLRPC::Client, call: nil) }
    let(:retries) { 3 }

    subject(:connection) { build(:connection, retries: retries) }

    before do
      allow_any_instance_of(GenePool).to receive(:with_connection_auto_remove).and_yield(client)
    end

    it 'delegates method execution to a XMLRPC::Client instance' do
      connection.call('endpoint', 'original_params', 'arg1', 'arg2')

      expect(client).to have_received(:call).with('endpoint', 'arg1', 'arg2')
    end

    shared_examples_for 'retrying the call' do |error, error_description|
      before do
        allow(client).to receive(:call).and_raise(error)
      end

      it "retries the call for as many retries configured if #{error_description} is raised" do
        connection.call('endpoint', 'arg1', 'arg2') rescue nil

        expect(client).to have_received(:call).exactly(retries + 1).times
      end

      it 'raises the original error once retries are exhausted' do
        expect{ connection.call('endpoint', 'arg1', 'arg2') }.to raise_error(error)
      end
    end

    Klarna::ErrorHandling::RETRYABLE_ERRORS.each do |retryable_error|
      it_behaves_like 'retrying the call', retryable_error, "a #{retryable_error}"
    end

    Klarna::Constants::TIMEOUT_FAULT_CODES.each do |faultCode|
      it_behaves_like 'retrying the call', XMLRPC::FaultException.new(faultCode, 'Timeout'), "an XMLRPC::FaultException with faultCode: #{faultCode}"
    end

    it_behaves_like 'retrying the call', RuntimeError.new('HTTP-Error: 500 Internal Server Error'), "a RuntimeError with message: 'HTTP-Error: 500 Internal Server Error'"

    it_behaves_like 'retrying the call', RuntimeError.new('HTTP-Error: 503 Service Unavailable'), "a RuntimeError with message: 'HTTP-Error: 503 Service Unavailable'"

    it_behaves_like 'retrying the call', Net::OpenTimeout.new('execution expired'), "a Net::OpenTimeout with message: 'execution expired'"
  end
end
