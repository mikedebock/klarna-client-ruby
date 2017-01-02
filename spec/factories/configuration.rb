FactoryGirl.define do
  factory :configuration, :class => Klarna::Configuration do
    hostname     { ENV['KLARNA_HOST'] }
    port         { ENV['KLARNA_PORT'] }
    store_id     { ENV['KLARNA_STORE_ID'].to_i }
    store_secret { ENV['KLARNA_STORE_SECRET'] }
    retries      { ENV['RETRIES'] }
    sleep        { ENV['SLEEP'] }
    client_name  { ENV['CLIENT_NAME'] }

    initialize_with { new(hostname, port, store_id, store_secret, retries, sleep) }
  end
end
