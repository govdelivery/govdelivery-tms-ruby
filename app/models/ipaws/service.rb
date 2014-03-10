module IPAWS
  class Service

    # The SOAP service that implements this API.
    class_attribute :soap_service

    # Default to the sample SOAP service.
    self.soap_service = SampleSoapService.new
    if defined?(java_import)
      # Add import of Java SOAP service here.
    end

    def self.ack?
      # Returns true if successful getAck response received from IPAWS.
      !!soap_service.getAck
    end

    def self.cog_profile
      soap_service.getCOGProfile
    end

    def self.create_alert(attributes)
      soap_service.postMessage(attributes)
    end

  end
end

