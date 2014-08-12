require_relative 'base'

module Transformers
  class AceTrain < Base
    def accepted_format
      "application/json"
    end

    def transform
      formatted_payload.empty? ? '' : formatted_payload[:smsText]
    end
  end
end