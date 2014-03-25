# put the stuff you don't want lazily loaded ever in here

require 'command_type/base'

if defined?(JRUBY_VERSION)
  LockJar.load
  java_import com.govdelivery.ipaws.IPAWSClient
end
