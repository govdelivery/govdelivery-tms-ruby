# This service is essentially a wrapper to Keywords to handle the case of someone texting in to a shared vendor without specifying
# a prefix or the (more common) case of someone texting a special keyword, basically it wraps the keywords so that we can still
# have custom keyword commands that get executed, but still handle the additional things that we need to do for our special keyword,
# such as creating or deleting stop_requests

module Service
  class Keyword

    attr_reader :keyword, :type, :account, :vendor, :text

    DEFAULT_STOP_TEXT = "You will no longer receive SMS messages."
    DEFAULT_START_TEXT = "Welcome to GovDelivery SMS Alerts. Msg&data rates may apply. Reply HELP for help, STOP to cancel. http://govdelivery.com/wireless for more help. 5 msg/wk."
    DEFAULT_HELP_TEXT = "This service is provided by GovDelivery. If you are a customer in need of assistance, please contact customer support."

    def initialize(text, account_id = nil, vendor = nil)
      @text = text
      @type = special_name(text)
      @account = Account.find(account_id) if account_id
      @keyword = get_keyword(text)
      @vendor = vendor
    end

    def default?
      !!self.keyword.try(:default?) || vendor_default?
    end

    def respond!(command_parameters)
      execute_commands(command_parameters)
      response_text
    end

    def response_text
      return DEFAULT_HELP_TEXT if vendor_default?
      self.keyword.try(:response_text) || (self.type && self.class.const_get("DEFAULT_#{self.type.upcase}_TEXT"))
    end

    private

    def vendor_default?
      !(self.keyword || self.type)
    end

    def get_keyword(text)
      return unless @account
      @account.keywords.where(name: self.type || self.text).first || self.account.default_keyword
    end

    def execute_commands(command_parameters)
      target = self.account || self.vendor
      self.type ? target.try(:"#{self.type}!", command_parameters) : self.keyword.try(:execute_commands, command_parameters)
    end

    def special_name(text)
      ['start', 'stop', 'help'].detect { |name| ::Keyword.const_get("#{name.upcase}_WORDS").include? text }
    end
  end
end