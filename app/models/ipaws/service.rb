module IPAWS
  class Service

    # The SOAP service that implements this API.
    class_attribute :soap_service

    if defined?(java_import)
      # Add import of Java SOAP service here.
    end

    def self.ack?
      # Returns true if successful getAck response received from IPAWS.
      !!soap_service.try(:getAck);
    end

  end
end