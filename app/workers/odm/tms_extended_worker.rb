require 'base'

module Odm
  TMS_EXTENDED_WORKER = 'Odm::TmsExtendedSenderWorker'

  class TmsExtendedWorker
    include ::Workers::Base

    def self.jruby?
      defined?(JRUBY_VERSION)
    end

    def perform(*options)
      raise NotImplementedError.new("#{self.class.name} requires JRuby") unless self.class.jruby?

      begin
        yield
      rescue Java::ComGovdeliveryTmsTmsextended::TMSFault => fault
        raise "ODM Error: #{fault.message}"
      rescue Java::java::lang::Throwable => throwable
        raise "#{throwable.get_message}"
      end
    end

    if jruby?
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

    def credentials(vendor)
      cred=Credentials.new
      cred.username=vendor.username
      cred.password=vendor.password
      cred
    end

    def with_recipient(event, scope)
      logger.debug { "#{self.class}: handling #{event.inspect}" }
      if(id=parse_recipient_id(event.recipient_id))
        if(recipient = find_recipient(id, scope))
          yield recipient
        end
      end
    end

    # It would be interesting to know if we are given a recipient
    # id that can't be found... hence the muss and fuss about 
    # RecordNotFound (as opposed to find_by_id)
    def find_recipient(recip_id, scope)
      scope.find(recip_id)
    rescue ActiveRecord::RecordNotFound => e
      logger.warn("#{self.class.name}: Couldn't find recipient #{recip_id}")
      nil
    end

    # The recipient id we send to ODM is an integer, and we should be 
    # getting an integer back from ODM.  This might seem like overkill, 
    # but there is actually a bug in ODM where we get statistics from 
    # other accounts back and the recipient_id can't be parsed as an integer.
    def parse_recipient_id(recip_id)
      Integer(recip_id)
    rescue ArgumentError, TypeError => e
      logger.warn("#{self.class.name}: Couldn't parse recipient id '#{recip_id}' into an integer.")
      nil
    end
  end
end