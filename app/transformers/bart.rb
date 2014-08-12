require_relative 'base'

module Transformers
  class Bart < Base
    def accepted_format
      "text/html"
    end

    def transform
      formatted_payload
    end
  end
end