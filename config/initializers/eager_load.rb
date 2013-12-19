# put the stuff you don't want lazily loaded ever in here

require 'command_type/base'

if defined?(JRUBY_VERSION)
  require 'tms_extended.jar'
  $CLASSPATH << "lib/tms_extended.jar"
end
