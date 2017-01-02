require 'spec_helper'

describe Klarna::ErrorHandling do
  describe Klarna::ErrorHandling::ErrorHandler do
    describe '#on_retry' do
      let(:error_handler) { Klarna::ErrorHandling::ErrorHandler.new(3, 'method', %w(arg1 arg2))}

      # This is due to a bug in ruby's OpenSSL implementation (See https://bugs.ruby-lang.org/issues/7215 for more details)
      context 'when SSL errors exist' do
        before { allow(OpenSSL).to receive(:errors).and_return(%w(error1 error2)) }

        it 'clears ssl errors' do
          error_handler.on_retry(1) { 'do nothing' }

          expect(OpenSSL.errors).to be_empty
        end

        it 'logs OpenSSL.errors' do
          expect(Klarna.configuration.logger).to receive(:warn).with({message: "Clearing SSL errors", errors: "error1, error2"})

          error_handler.on_retry(1) { 'do more nothing' }
        end
      end

      it 'yields' do
        expect{ |b| error_handler.on_retry(10, &b) }.to yield_with_no_args
      end

      context 'given a block that raises an error' do
        before { stub_const('Klarna::ErrorHandling::IGNORED_ERRORS', [Klarna::ErrorHandling::IgnoredError.new(klass: StandardError)]) }

        it 'raises a Klarna::ErrorHandling::RetryableError when its type matches one of the IGNORED_ERRORS' do
          expect { error_handler.on_retry(1) { raise StandardError } }.to raise_error Klarna::ErrorHandling::RetryableError
        end

        it 'raises the same error when its type does not match one of the IGNORED_ERRORS' do
          error = Exception.new

          expect { error_handler.on_retry(1) { raise error } }.to raise_error(error)
        end

        it 'raises the same error when its type matches one of the IGNORED_ERRORS and retries have been exhausted' do
          error = StandardError.new

          expect { error_handler.on_retry(3) { raise error } }.to raise_error(error)
        end

        it 'raises the same error when its type does not match one of the IGNORED_ERRORS and retries have been exhausted' do
          error = Exception.new

          expect { error_handler.on_retry(3) { raise error } }.to raise_error(error)
        end
      end
    end
  end

  describe Klarna::ErrorHandling::IgnoredError do
    describe '#matches?' do
      it 'returns true when error types match' do
        ignored_error = Klarna::ErrorHandling::IgnoredError.new(klass: StandardError)
        expect(ignored_error.matches?(StandardError.new)).to be_truthy
      end

      it 'returns false when error types do not match' do
        ignored_error = Klarna::ErrorHandling::IgnoredError.new(klass: StandardError)
        expect(ignored_error.matches?(Exception.new)).to be_falsey
      end

      it 'returns true when error types and messages match' do
        ignored_error = Klarna::ErrorHandling::IgnoredError.new(klass: StandardError, message: /a standard error/)
        expect(ignored_error.matches?(StandardError.new('this is a standard error'))).to be_truthy
      end

      it 'returns false when messages do not match' do
        ignored_error = Klarna::ErrorHandling::IgnoredError.new(klass: StandardError, message: /a standard error/)
        expect(ignored_error.matches?(StandardError.new('a similar standard error'))).to be_falsey
      end

      it 'returns true when error types, messages and allowed values match' do
        ignored_error  = Klarna::ErrorHandling::IgnoredError.new(klass: StandardError, message: /a standard error/, allowed_values: { backtrace: [['backtrace1'], ['backtrace2']] })
        matching_error = StandardError.new('a standard error')
        matching_error.set_backtrace('backtrace1')
        expect(ignored_error.matches?(matching_error)).to be_truthy
      end

      it 'returns false when allowed values do not match' do
        ignored_error  = Klarna::ErrorHandling::IgnoredError.new(klass: StandardError, message: /a standard error/, allowed_values: { backtrace: %w(backtrace1 backtrace2) })
        matching_error = StandardError.new('a standard error')
        matching_error.set_backtrace('backtrace3')
        expect(ignored_error.matches?(matching_error)).to be_falsey
      end
    end
  end

  describe '.for' do
    it 'creates a Klarna::ErrorHandling::ErrorHandler' do
      allow(Klarna::ErrorHandling::ErrorHandler).to receive(:new).with(3, 'foo', %w(arg1 arg2)).and_return('Handling errors since 1980')

      expect(Klarna::ErrorHandling.for(max_retries: 3, method: 'foo', args: %w(arg1 arg2))).to eq 'Handling errors since 1980'
    end
  end

  describe Klarna::ErrorHandling::ConceivablyIgnorable do
    describe '#with' do
      let(:error) { Exception.new.extend Klarna::ErrorHandling::ConceivablyIgnorable }

      before do
        class << error
          attr_accessor :method_name, :method_params
        end
      end

      it 'sets :method_name and :method_params' do
        error.with('abra', 'cadabra')

        expect(error.method_name).to eq 'abra'
        expect(error.method_params).to eq 'cadabra'
      end

      it 'returns itself' do
        expect(error.with('abra', 'cadabra')).to eq error
      end
    end

    describe 'ignore_or_raise' do
      before do
        stub_const('Klarna::ErrorHandling::IGNORED_ERRORS', [Klarna::ErrorHandling::IgnoredError.new(klass: XMLRPC::FaultException, allowed_values: { faultCode: [7554] })])
      end

      context 'given the error matches one of the IGNORED_ERRORS' do
        let(:error) { XMLRPC::FaultException.new(7554, "Hello").extend Klarna::ErrorHandling::ConceivablyIgnorable }

        it 'logs the error' do
          expect(Klarna.configuration.logger).to receive(:warn).with({message: "An error occurred while calling Klarna XMLRPC. Retrying!",
                                                                      action: nil,
                                                                      error: {type: XMLRPC::FaultException, message: "Hello", faultCode: 7554},
                                                                      request_body: nil})

          error.ignore_or_raise rescue nil
        end

        it 'raises a Klarna::ErrorHandling::RetryableError' do
          expect { error.ignore_or_raise }.to raise_error Klarna::ErrorHandling::RetryableError
        end
      end

      context 'given the error does not match one of the IGNORED_ERRORS' do
        let(:error) { Exception.new.extend Klarna::ErrorHandling::ConceivablyIgnorable }

        it 'raises itself' do
          expect { error.ignore_or_raise }.to raise_error error
        end
      end
    end
  end
end
