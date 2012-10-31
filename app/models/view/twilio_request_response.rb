module View
  class TwilioRequestResponse
    attr_accessor :vendor, :request

    # The incoming request body (the thing someone texted to us)
    def request
      @request || ""
    end

    # What we will text back to the persion via Twilio  
    def response_text
      self.stop? ? vendor.stop_text : vendor.help_text
    end

    # Delegate missing methods to the vendor object, so that the RablResponder can
    # render appropriate responses based on the status of that model.
    def method_missing(method_name, *args)
      vendor.send(method_name, *args)
    end

    def initialize(attributes={})
      attributes.each do |k,v|
        self.send "#{k}=", v
      end
    end

    def stop?
      !!(request =~ /stop/i)
    end

    def help?
      !stop?
    end
  end
end