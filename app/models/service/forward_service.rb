require 'typhoeus/adapters/faraday'
module Service
  class ForwardService
    include MassAssignment

    attr_accessor :logger

    def post(url, username, password, body)
      connection(username, password).post(url) do |req|
        req.body = body
      end
    end

    def get(url, username, password, body)
      connection(username, password).get(url) do |req|
        req.params = body
      end
    end

    def connection(username, password)
      Faraday.new do |faraday|
        faraday.use Faraday::Response::Logger, self.logger if self.logger
        faraday.use Faraday::Response::RaiseError
        faraday.basic_auth(username, password) if username && password
        faraday.adapter :typhoeus
      end
    end
  end
end