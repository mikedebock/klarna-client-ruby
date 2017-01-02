module ConfigurationHelper
  def setup_configuration
    Klarna.configure do |config|
      config.hostname     = ENV['KLARNA_HOST']
      config.port         = ENV['KLARNA_PORT']
      config.store_id     = ENV['KLARNA_STORE_ID'].to_i
      config.store_secret = ENV['KLARNA_STORE_SECRET']
      config.retries      = ENV['RETRIES']
      config.client_name  = ENV['CLIENT_NAME']
      config.logger       = Logger.new('/dev/null')
    end
  end
end
