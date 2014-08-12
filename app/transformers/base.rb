require 'json'

module Transformers
  class Base
    def initialize(payload, format)
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
      return '' unless acceptable_format?
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
        ''
      end
    end
  end
end
