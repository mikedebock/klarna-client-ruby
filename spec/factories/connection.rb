FactoryGirl.define do
  factory :connection, :class => Klarna::Connection do
    xmlrpc_hostname { ENV['KLARNA_HOST'] }
    xmlrpc_port     { ENV['KLARNA_PORT'] }
    retries         { 3 }
    sleep           { 0 }
    timeout         { 70 }

    initialize_with { new(xmlrpc_hostname, xmlrpc_port, retries, sleep, timeout) }
  end
end
