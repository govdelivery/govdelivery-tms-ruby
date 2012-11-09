module View
  class TwilioRequestResponse
    attr_accessor :request_parser, :vendor

    # What we will text back to the persion via Twilio  
    def response_text
      self.request_parser.stop? ? vendor.stop_text : vendor.help_text
    end

    # Delegate missing methods to the vendor object, so that the RablResponder can
    # render appropriate responses based on the status of that model.
    def method_missing(method_name, *args)
      request_parser.vendor.send(method_name, *args)
    end

    def initialize(vendor, request_parser)
      self.vendor = vendor
      self.request_parser = request_parser
    end
  end
end