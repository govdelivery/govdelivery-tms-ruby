if defined?(JRUBY_VERSION)
  $CLASSPATH << "lib/tms_extended.jar"
  require 'tms_extended.jar'
end
