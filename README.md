# Klarna Ruby Client

An XMLRPC client for Klarna's API.

## Installation

Switch the RubyGems source to nexus

    source 'https://nexus.int.klarna.net/content/groups/publicgems'

Add this line to your application's Gemfile:

    gem 'klarna-client-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install klarna-client-ruby --source 'https://nexus.int.klarna.net/content/groups/publicgems'

## Supported methods

  * [activate](https://developers.klarna.com/en/se+php/kpm/order-management-api#activate)
  * `add_invoice` - the old `reserve_amount`. It creates never expiring passive invoices that must be activated.
  * [cancel_reservation](https://developers.klarna.com/en/se+php/kpm/order-management-api#cancel_reservation)
  * [check_order_status](https://developers.klarna.com/en/se+php/kpm/order-management-api#check_order_status)
  * `create_prepaid_order` - an API call specifically for On-Demand. This is used to bookkeep a credit card
    purchase. Read the tests in `spec/lib/klarna/client_spec.rb` for usage.
  * [credit_invoice](https://developers.klarna.com/en/se+php/kpm/order-management-api#credit_invoice)
  * [credit_part](https://developers.klarna.com/en/se+php/kpm/order-management-api#credit_part) - aside from the
    documented features there, if you have an 'aggregated invoice' (`Klarna::Constants::AGGREGATED_INVOICE_FLAG`),
    then you can _add_ items to the goods list. See tests for `credit_part` in `spec/lib/klarna/client_spec.rb` for
    usage.
  * [get_addresses](https://developers.klarna.com/en/se+php/kpm/checkout-api#get_addresses)
  * `get_payref_id` - an API call specifically for On-Demand. Returns an ID which can be used in a `create_prepaid_order`
    call to bookkeep a credit card purchase
  * reserve_amount(https://developers.klarna.com/en/se+php/kpm/checkout-api#reserve_amount)
  * lookup_invoice - returns a list of available invoice numbers by providing a random 'orderid1' value (previously passed as optional info in activate or reserve methods) 
  * order_info - returns a list of order information by providing an invoice number
  * extend_invoice_due_date - returns a date and cost and optionally extends the invoice due date by providing an invoice number and a flag

## Usage

### Single store configuration

First, set up the connection settings to Klarna's API server.

    Klarna.configure do |config|
      config.hostname            = 'payment.testdrive.klarna.com'
      config.port                = 443
      config.store_id            = 7
      config.store_secret        = 'supersecret'
      config.retries             = 2
      config.sleep               = 0.1
      config.client_name         = 'ruby-client'
      config.pool_size           = 2    # Should be set to the number of threads you have
      config.pool_timeout        = 10   # How long to wait for a new connection from the pool before erroring
      config.pool_warn_timeout   = 2    # How long to wait before logging that it's taking a while to get a connection
      config.pool_idle_timeout   = 60   # How long to keep an inactive connection before removing it from the pool
      config.use_instrumentation!       # Whether to send notifications using ActiveSupport::Notifications (default false)
    end

The Klarna client makes use of an XMLRPC::Client connection pool - read GenePool's [code](https://github.com/bpardee/gene_pool/blob/master/lib/gene_pool.rb#L12)
for more information on what each of the pool variables mean. You will want to set the `pool_size`
to equal the number of threads that you will have.

You can then execute any API request without suplying credentials:

    Klarna::Client.get_addresses(:pno => '410321-9202',
                                 :pno_encoding => Klarna::Constants::GET_ADDRESSES_PNO_ENCODING_SE,
                                 :type => Klarna::Constants::GET_ADDRESSES_TYPE_PNO)


### Multiple stores configuration

Create a client on every single request you want to make:

    client = Klarna::Client.new({
      :hostname     => 'payment.testdrive.klarna.com',
      :port         => 443,
      :store_id     => 7,
      :store_secret => 'dr.alban',
      :retries      => 2,
      :sleep        => 0.1,
      :client_name  => 'client-mcclient'
    })

You can execute any API request by using the client connection set up above:

    client.get_addresses(:pno => '410321-9202',
                         :pno_encoding => Klarna::Constants::GET_ADDRESSES_PNO_ENCODING_SE,
                         :type => Klarna::Constants::GET_ADDRESSES_TYPE_PNO)

### Ping
After configuring the client you may query the availability of Klarna's API using the following call:

    Klarna::Client.ping

    In case the call succeeds, it will return [true, nil]
    In case the call fails, it will return [false, nil]
    In case of an error, it will return [false, error]

## SystemReadinessChecker

The Gem exposes a SystemReadinessChecker.

Example usage within the `system_readiness.rb` initializer

    SystemReadiness.configure do |config|
      config.add Klarna::FredChecker.new
    end

Note that you need to require the system_readiness Gem before this Gem for the checker to be defined.

## Development and Testing

There are sane defaults in `.env`. If you want to connect to a different server, modify the file to
define the credentials of your Klarna's test API server:

    KLARNA_HOST: <hostname>
    KLARNA_PORT: <port>
    KLARNA_STORE_ID: <store_id>
    KLARNA_STORE_SECRET: <store_secret>
    RETRIES: <retries>
    SLEEP: <sleep>

## Contributing

1. Create your feature branch (`git checkout -b my-new-feature`)
    - do your stuff
    - create tests
    - run `bundle exec rspec` and verify all tests pass
    - update `version.rb` by following [semantic versioning](http://semver.org/)
    - update `CHANGELOG.md` 
2. Commit your changes (`git commit -am 'Add some feature'`)
3. Push to the branch (`git push origin my-new-feature`)
4. Create a new Pull Request
5. Merge to master once approved

## License

[Apache 2.0](LICENSE)
