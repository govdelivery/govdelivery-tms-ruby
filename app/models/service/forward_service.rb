require 'typhoeus/adapters/faraday'
module Service
  class ForwardService
    USER_AGENT = "Mozilla/5.0 (compatible; GovDelivery TMS v1.0; http://govdelivery.com)"

    attr_accessor :logger

    def initialize(logger=nil)
      self.logger = logger
    end

    def post(url, username, password, body)
      connection(username, password).post(url) do |req|
        req.body = body
      end
    end

    def get(url, username, password, body)
      connection(username, password).get(url) do |req|
        req.headers[:user_agent] = '2' # Header
        req.params.merge!(body)
      end
    end

    def connection(username, password)
      Faraday.new do |faraday|
        faraday.headers[:user_agent] = USER_AGENT
        faraday.use Faraday::Response::Logger, self.logger if self.logger
        faraday.use Faraday::Response::RaiseError
        faraday.basic_auth(username, password) if username && password
        faraday.adapter :typhoeus
      end
    end
  end
end