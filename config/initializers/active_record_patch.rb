# XACT-703: Remove once we get to jruby-1.7.22
if Gem::Version.new(JRUBY_VERSION) < Gem::Version.new('1.7.21')
  module ActiveSupport
    class Duration
      alias_method :to_int, :to_i
    end
    class TimeWithZone
      def localtime(utc_offset = nil)
        utc.respond_to?(:getlocal) ? utc.getlocal : utc.to_time.getlocal
      end
    end
  end
else
  Rails.logger.error("Jruby newer than 1.7.22 detected, if this is in PRD we can remove this aweful monkey patch")
end
