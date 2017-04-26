module GovDelivery
  module TMS #:nodoc:
  end
end

require 'active_support/core_ext/hash'
require 'govdelivery/tms/version'
require 'faraday'
require 'faraday_middleware'

require 'govdelivery/tms/link_header'
require 'govdelivery/tms/util/hal_link_parser'
require 'govdelivery/tms/util/core_ext'
require 'govdelivery/tms/connection'
require 'govdelivery/tms/client'
require 'govdelivery/tms/logger'
require 'govdelivery/tms/base'
require 'govdelivery/tms/instance_resource'
require 'govdelivery/tms/collection_resource'
require 'govdelivery/tms/errors'

require 'govdelivery/tms/resource/collections'
require 'govdelivery/tms/resource/recipient'
require 'govdelivery/tms/resource/email_recipient'
require 'govdelivery/tms/resource/email_recipient_open'
require 'govdelivery/tms/resource/email_recipient_click'
require 'govdelivery/tms/resource/from_address'
require 'govdelivery/tms/resource/email_template'
require 'govdelivery/tms/resource/sms_template'
require 'govdelivery/tms/resource/sms_message'
require 'govdelivery/tms/resource/email_message'
require 'govdelivery/tms/resource/inbound_sms_message'
require 'govdelivery/tms/resource/command_type'
require 'govdelivery/tms/resource/message_type'
require 'govdelivery/tms/resource/command_action'
require 'govdelivery/tms/resource/command'
require 'govdelivery/tms/resource/keyword'
require 'govdelivery/tms/resource/webhook'
