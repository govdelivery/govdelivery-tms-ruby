require 'json'

module Transformers
  class InvalidResponse < StandardError

  end

  class Base
    def initialize(format, payload)
      @payload = payload
      @format = format
    end

    def accepted_format
      raise NotImplementedError
    end

    def acceptable_format?
      @format == accepted_format
    end

    def formatted_payload
      on_invalid_format unless acceptable_format?
      @formatted_payload ||= case @format
      when "application/json"
        begin
          JSON.parse(@payload, symbolize_names: true)
        rescue JSON::ParserError
          ''
        end
      when "text/html", "text/plain"
        @payload
      else
        on_invalid_format
      end
    end

    protected

    def on_invalid_format
      raise Transformers::InvalidResponse.new("invalid content type: #{@format}")
    end
  end
end
