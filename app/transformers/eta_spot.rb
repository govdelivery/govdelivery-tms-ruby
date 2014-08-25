require_relative 'base'

module Transformers
  class EtaSpot < Base
    def accepted_format
      "application/json"
    end

    def transform
      formatted_payload[:get_stop_etas][0][:smsText]
    rescue Transformers::InvalidResponse
      raise
    rescue
      raise Transformers::InvalidResponse.new("got invalid response body '#{@payload}'")
    end
  end

end