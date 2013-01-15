require 'base'

class TmsWorker
  include Workers::Base

  def self.jruby?
    defined?(JRUBY_VERSION)
  end

  if jruby?
    require 'lib/odm.jar'
    java_import com.govdelivery.odm.odmv2.Credentials
    java_import com.govdelivery.odm.odmv2.Message
    java_import com.govdelivery.odm.odmv2.ODMv2_Service
    java_import com.govdelivery.odm.odmv2.ODMv2
  end

  def self.vendor_type
    :email
  end

  def perform(options)
    raise NotImplementedError.new("TmsWorker requires JRuby") unless self.class.jruby?
    vendor = Account.find_by_id(options['account_id']).email_vendor

    cred=Credentials.new
    cred.username=vendor.username
    cred.password=vendor.password

    email_params = options['email']
    msg = Message.new # this is an com.govdelivery.odm.odmv2.Message, not an XACT Message
    msg.subject = email_params['subject']
    msg.body = email_params['body']
    msg.from_name = email_params['from']
    msg.email_column = 'email'
    msg.record_designator='email'
    email_params['recipients'].each { |recipient| msg.to << recipient }
    tms.send_message(cred, msg)
  end

  def tms
    tms_service = ODMv2_Service.new
    tms_service.getODMv2Port
  end
end
