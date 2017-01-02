require 'spec_helper'

describe Klarna::Configuration do
  subject { Klarna::Configuration.new }

  it { should respond_to(:hostname) }
  it { should respond_to(:port) }
  it { should respond_to(:retries) }
  it { should respond_to(:sleep) }
  it { should respond_to(:store_id) }
  it { should respond_to(:store_secret) }
  it { should respond_to(:timeout) }
  it { should respond_to(:client_name) }
  it { should respond_to(:use_instrumentation?) }
  it { should respond_to(:use_instrumentation!) }
end
