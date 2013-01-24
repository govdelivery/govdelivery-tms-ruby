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
    java_import com.govdelivery.tms.tmsextended.ExtendedMessage
    java_import com.govdelivery.tms.tmsextended.TMSExtended_Service
    java_import com.govdelivery.tms.tmsextended.TMSExtended
  end

  def self.vendor_type
    :email
  end

  def perform(options)
    raise NotImplementedError.new("#{self.class.name} requires JRuby") unless self.class.jruby?

    message = EmailMessage.find(options['message_id'])

    vendor = message.vendor

    cred=Credentials.new
    cred.username=vendor.username
    cred.password=vendor.password

    msg = ExtendedMessage.new
    msg.subject = message.subject
    msg.body = message.body
    msg.from_name = message.from_name || ''

    msg.email_column = 'email'
    msg.record_designator='email'
    message.recipients.find_each { |recipient| msg.to << recipient.email }
    ack = odm.send_message(cred, msg)
    message.sending!
  end

  def odm
    odm_service = TMSExtended_Service.new(URL.new(Rails.configuration.odm_endpoint))
    odm_service.getTMSExtendedPort
  end
end
