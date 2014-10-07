module Keywords
  DEFAULT_STOP_TEXT = "You will no longer receive SMS messages."
  DEFAULT_START_TEXT = "Welcome to GovDelivery SMS Alerts. Msg&data rates may apply. Reply HELP for help, STOP to cancel. http://govdelivery.com/wireless for more help. 5 msg/wk."
  DEFAULT_HELP_TEXT = "This service is provided by GovDelivery. If you are a customer in need of assistance, please contact customer support."

  # We always want to respond to stop, help and start.
  # Account.find(x).default_keyword.update_attribute :response_text, "wut"
  # Account.find(x).stop_keyword.update_attribute :response_text, "no way man"
  # SmsVendor.find(x).start_keyword.update_attribute :response_text, "let's get it on"

  class SpecialKeyword < Keyword
    self.table_name = 'keywords'
    self.abstract_class = true
    attr_accessible :vendor, :account

    def name=(n)
      write_attribute(:name, n) #leave uppercase
    end

    def special?
      true
    end
  end

  class VendorStop < SpecialKeyword

    def response_text
      read_attribute(:response_text) || DEFAULT_STOP_TEXT
    end

    def execute_commands(command_parameters)
      vendor.stop!(command_parameters)
    end
  end

  class VendorStart < SpecialKeyword

    def response_text
      read_attribute(:response_text) || DEFAULT_START_TEXT
    end

    def execute_commands(command_parameters)
      vendor.start!(command_parameters)
    end
  end

  class VendorHelp < SpecialKeyword

    def response_text
      read_attribute(:response_text) || DEFAULT_HELP_TEXT
    end

    def execute_commands(command_parameters)
      #noop
      Rails.logger.info("Keywords::VendorHelp: #{command_parameters}" )
    end
  end

  class VendorDefault < SpecialKeyword

    # default response text is optional
    # can be remove if a command will respond instead
    before_create ->{ self.response_text = DEFAULT_HELP_TEXT if self.response_text.nil? }

    def default?
      true
    end
  end

  class AccountStop < SpecialKeyword

    def response_text
      read_attribute(:response_text) || DEFAULT_STOP_TEXT
    end

    def execute_commands(command_parameters)
      account.stop!(command_parameters)
    end
  end

  class AccountHelp < SpecialKeyword

    def response_text
      read_attribute(:response_text) || DEFAULT_HELP_TEXT
    end

    def execute_commands(command_parameters)
      #noop
      Rails.logger.info("Keywords::AccountHelp: #{command_parameters}" )
    end
  end

  class AccountDefault < SpecialKeyword

    # default response text is optional
    # can be remove if a command will respond instead
    before_create ->{ self.response_text = DEFAULT_HELP_TEXT if self.response_text.nil? }

    def default?
      true
    end
  end
end
