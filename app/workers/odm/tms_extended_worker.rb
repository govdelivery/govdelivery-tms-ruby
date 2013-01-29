require 'base'

module Odm
  TMS_EXTENDED_WORKER = 'Odm::TmsExtendedSenderWorker'

  class TmsExtendedWorker
    include ::Workers::Base

    def self.jruby?
      defined?(JRUBY_VERSION)
    end

    if jruby?
      require 'lib/tms_extended.jar'
      java_import java.net.URL
      java_import com.govdelivery.tms.tmsextended.Credentials
      java_import com.govdelivery.tms.tmsextended.ExtendedMessage
      java_import com.govdelivery.tms.tmsextended.TMSExtended_Service
      java_import com.govdelivery.tms.tmsextended.TMSExtended
      java_import com.govdelivery.tms.tmsextended.DeliveryActivity
      java_import com.govdelivery.tms.tmsextended.ActivityRequest
    end

    def odm
      odm_service = TMSExtended_Service.new(URL.new(Rails.configuration.odm_endpoint))
      odm_service.getTMSExtendedPort
    end

    def credentials
      cred=Credentials.new
      cred.username=Rails.configuration.odm_username
      cred.password=Rails.configuration.odm_password
      cred
    end

  end
end