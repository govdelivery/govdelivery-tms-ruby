module Keywords
  DEFAULT_STOP_TEXT = "You will no longer receive SMS messages."
  DEFAULT_START_TEXT = "Welcome to GovDelivery SMS Alerts. Msg&data rates may apply. Reply HELP for help, STOP to cancel. http://govdelivery.com/wireless for more help. 5 msg/wk."
  DEFAULT_HELP_TEXT = "This service is provided by GovDelivery. If you are a customer in need of assistance, please contact customer support."

  class Start
    def initialize(account = nil, vendor = nil)
      @account = account
      @vendor = vendor
    end

    def default?
      false
    end

    def response_text
      DEFAULT_START_TEXT
    end

    def execute_commands(command_parameters)
      @account.try(:start!, command_parameters) || @vendor.try(:start!, command_parameters)
    end
  end

  class Stop
    def initialize(account = nil, vendor = nil)
      @account = account
      @vendor = vendor
    end

    def default?
      false
    end

    def response_text
      @account.try(:stop_text) || DEFAULT_STOP_TEXT
    end

    def create_command(params)
      @account.stop_keyword.try(:create_command, params) if @account
    end

    def execute_commands(command_parameters)
      @account.try(:stop!, command_parameters) || @vendor.try(:stop!, command_parameters)
    end
  end

  class Help
    def initialize(account = nil)
      @account = account
    end

    def default?
      false
    end

    def response_text
      @account.try(:help_text) || DEFAULT_HELP_TEXT
    end

    def create_command(params)
      @account.help_keyword.try(:create_command, params) if @account
    end

    def execute_commands(command_parameters)
      @account.try(:help, command_parameters)
    end
  end
end
