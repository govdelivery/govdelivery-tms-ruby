# put the stuff you don't want lazily loaded ever in here

require 'command_type/base'

LockJar.load if defined?(JRUBY_VERSION)
