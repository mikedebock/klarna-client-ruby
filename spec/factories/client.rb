FactoryGirl.define do
  factory :client, :class => Klarna::Client do
    hostname     { ENV['KLARNA_HOST'] }
    port         { ENV['KLARNA_PORT'] }
    store_id     { ENV['KLARNA_STORE_ID'].to_i }
    store_secret { ENV['KLARNA_STORE_SECRET'] }
    retries      { 3 }
    sleep        { 0.2 }
    client_name  { ENV['CLIENT_NAME'] }

    initialize_with do
      new({
        :hostname     => hostname,
        :port         => port,
        :retries      => retries,
        :sleep        => sleep,
        :store_id     => store_id,
        :store_secret => store_secret,
        :client_name  => client_name
      })
    end
  end
end
