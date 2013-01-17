require 'delegate'

module View
  class TwilioRequestResponse < SimpleDelegator
    attr_reader :vendor, :response_text
    def initialize(vendor, response_text)
      @vendor = vendor
      @response_text = response_text
      super(@vendor)
    end
  end
end
