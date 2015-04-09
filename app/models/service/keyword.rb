# This service is essentially a wrapper to Keywords to handle the case of someone texting in to a shared vendor without specifying
# a prefix or the (more common) case of someone texting a special keyword, basically it wraps the keywords so that we can still
# have custom keyword commands that get executed, but still handle the additional things that we need to do for our special keyword,
# such as creating or deleting stop_requests

module Service
  class Keyword
    attr_reader :keyword, :type, :account, :vendor, :text

    DEFAULT_STOP_TEXT = 'You will no longer receive SMS messages.'
    DEFAULT_START_TEXT = 'Welcome to GovDelivery SMS Alerts. Msg&data rates may apply. Reply HELP for help, STOP to cancel. http://govdelivery.com/wireless for more help. 5 msg/wk.'
    DEFAULT_HELP_TEXT = 'This service is provided by GovDelivery. If you are a customer in need of assistance, please contact customer support.'

    def initialize(text, account_id = nil, vendor = nil)
      @text = text
      @type = special_name(text)
      @account = Account.find(account_id) if account_id
      @keyword = get_keyword(text)
      @vendor = vendor
    end

    def default?
      !!keyword.try(:default?) || vendor_default?
    end

    def respond!(command_parameters)
      execute_commands(command_parameters)
      response_text
    end

    def response_text
      return vendor.try(:help_text) || DEFAULT_HELP_TEXT if vendor_default?
      keyword.try(:response_text) || (type && vendor_response_text)
    end

    private

    def vendor_response_text
      vendor.try(:"#{type}_text") || self.class.const_get("DEFAULT_#{type.upcase}_TEXT")
    end

    def vendor_default?
      !(keyword || type)
    end

    def get_keyword(_text)
      return unless @account
      @account.keywords.find_by(name: type || text) || account.default_keyword
    end

    def execute_commands(command_parameters)
      target = account || vendor
      type ? target.try(:"#{type}!", command_parameters) : keyword.try(:execute_commands, command_parameters)
    end

    def special_name(text)
      %w(start stop help).detect { |name| ::Keyword.const_get("#{name.upcase}_WORDS").include? text }
    end
  end
end
