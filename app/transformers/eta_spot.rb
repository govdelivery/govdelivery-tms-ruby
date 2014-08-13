require_relative 'base'

module Transformers
  class EtaSpot < Base
    def accepted_format
      "application/json"
    end

    def transform
      return '' if formatted_payload.empty? or formatted_payload[:get_stop_etas].empty?
      formatted_payload[:get_stop_etas][0][:smsText]
    end
  end
end