require File.expand_path('../sequence', __FILE__)
require File.expand_path('../fetcher', __FILE__)
require File.expand_path('../event_iterator', __FILE__)

module Service
  module Odm
    class EventService
      if defined?(JRUBY_VERSION)
        java_import java.net.URL
        java_import com.govdelivery.tms.tmsextended.Credentials
        java_import com.govdelivery.tms.tmsextended.ExtendedMessage
        java_import com.govdelivery.tms.tmsextended.TMSExtended_Service
        java_import com.govdelivery.tms.tmsextended.TMSExtended
        java_import com.govdelivery.tms.tmsextended.DeliveryActivity
        java_import com.govdelivery.tms.tmsextended.ActivityRequest
      end

      def self.delivery_events(vendor)
        event_iterator(vendor, :delivery)
      end

      def self.open_events(vendor)
        event_iterator(vendor, :open)
      end

      def self.click_events(vendor)
        event_iterator(vendor, :click)
      end

      def self.credentials(vendor)
        cred = Credentials.new
        cred.username = vendor.username
        cred.password = vendor.password
        cred
      end

      def self.event_iterator(vendor, type)
        creds = credentials(vendor)
        EventIterator.new(Fetcher.new(type, creds, odm), Sequence.new(type, vendor))
      end

      def self.odm
        odm_service = TMSExtended_Service.new(URL.new(Rails.configuration.odm_endpoint))
        odm_service.getTMSExtendedPort
      end
    end
  end
end
