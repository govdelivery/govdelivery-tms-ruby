module TSMS #:nodoc:
end

require 'active_support'
require 'tsms_client/version'
require 'faraday'
require 'link_header'
require 'faraday_middleware'

require 'tsms_client/util/hal_link_parser'
require 'tsms_client/util/core_ext'
require 'tsms_client/connection'
require 'tsms_client/client'
require 'tsms_client/logger'
require 'tsms_client/base'
require 'tsms_client/instance_resource'
require 'tsms_client/collection_resource'
require 'tsms_client/request'

require 'tsms_client/resource/collections'
require 'tsms_client/resource/recipient'
require 'tsms_client/resource/email_recipient'
require 'tsms_client/resource/sms_message'
require 'tsms_client/resource/voice_message'
require 'tsms_client/resource/inbound_message'
require 'tsms_client/resource/command_type'
require 'tsms_client/resource/keyword'
require 'tsms_client/resource/email'