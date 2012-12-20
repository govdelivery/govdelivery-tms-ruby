require 'typhoeus/adapters/faraday'
module Service
  class ForwardService
    include MassAssignable

    attr_accessor :connection, :logger

    def post(href, body)
      connection.post do |req|
        req.url href
        req.body = body.to_json
      end
    end

    def connection(url)
      Faraday.new(:url => url) do |faraday|
        faraday.use Faraday::Response::Logger, self.logger if self.logger
        faraday.use Faraday::Response::RaiseError

        faraday.request :text
        #faraday.basic_auth(self.username, self.password)
        faraday.response :text, :content_type => /\btext\/plain$/
        faraday.adapter :typhoeus
      end
    end
  end
end