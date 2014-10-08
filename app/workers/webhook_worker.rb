require 'base'
class WebhookWorker
  include Workers::Base
  sidekiq_options retry:    10,
                  queue:    :webhook

  READ_TIMEOUT = 10 #seconds
  CONN_TIMEOUT = 5 #seconds

  def perform(options)
    connection.post(options['url'], options['params']) do |req|
      req.options.timeout      = READ_TIMEOUT
      req.options.open_timeout = CONN_TIMEOUT
    end
  rescue Faraday::Error::TimeoutError => e
    raise
  rescue Faraday::Error::ClientError => e
    if (500..599).include?(e.response[:status])
      raise
    else
      logger.warn(e)
    end
    return
  end

  protected

  def connection
    Faraday.new do |faraday|
      faraday.use Faraday::Response::Logger, logger
      faraday.use Faraday::Response::RaiseError
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end
  end

end