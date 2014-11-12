# This service is essentially a wrapper to Keywords to handle the case of someone texting in to a shared vendor without specifying
# a prefix or the (more common) case of someone texting a special keyword, basically it wraps the keywords so that we can still
# have custom keyword commands that get executed, but still handle the additional things that we need to do for our special keyword,
# such as creating or deleting stop_requests

module Service
  class Keyword
    DEFAULT_STOP_TEXT = "You will no longer receive SMS messages."
    DEFAULT_START_TEXT = "Welcome to GovDelivery SMS Alerts. Msg&data rates may apply. Reply HELP for help, STOP to cancel. http://govdelivery.com/wireless for more help. 5 msg/wk."
    DEFAULT_HELP_TEXT = "This service is provided by GovDelivery. If you are a customer in need of assistance, please contact customer support."

    def initialize(type, account = nil, vendor = nil)
      @type = type
      @account = account
      @vendor = vendor
    end

    def default?
      false
    end

    def response_text
      (@account && @account.send(:"#{@type}_keyword").response_text) || self.class.const_get("DEFAULT_#{@type.upcase}_TEXT")
    end

    def execute_commands(command_parameters)
      @account.try(:"#{@type}!", command_parameters) || @vendor.try(:"#{@type}!", command_parameters)
    end

    def type
      @type
    end
  end
end