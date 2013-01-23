require 'base'

class OdmWorker
  include Workers::Base

  def self.jruby?
    defined?(JRUBY_VERSION)
  end

  if jruby?
    require 'lib/tms_extended.jar'
    java_import java.net.URL
    java_import com.govdelivery.tms.tmsextended.Credentials
    java_import com.govdelivery.tms.tmsextended.Message
    java_import com.govdelivery.tms.tmsextended.TMSExtended_Service
    java_import com.govdelivery.tms.tmsextended.TMSExtended
  end

  def self.vendor_type
    :email
  end

  def perform(options)
    raise NotImplementedError.new("#{self.class.name} requires JRuby") unless self.class.jruby?
    vendor = Account.find_by_id(options['account_id']).email_vendor

    cred=Credentials.new
    cred.username=vendor.username
    cred.password=vendor.password

    email_params = options['email']
    msg = Message.new # this is an com.govdelivery.tms.tmsextended.Message, not an XACT Message
    msg.subject = email_params['subject']
    msg.body = email_params['body']
    msg.from_name = email_params['from']
    msg.email_column = 'email'
    msg.record_designator='email'
    email_params['recipients'].each { |recipient| msg.to << recipient['email'] }
    odm.send_message(cred, msg)
  end

  def odm
    odm_service = TMSExtended_Service.new(URL.new(Rails.configuration.odm_endpoint))
    odm_service.getTMSExtendedPort
  end
end
