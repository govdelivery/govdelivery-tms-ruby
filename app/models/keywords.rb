module Keywords

  class SpecialKeyword < Keyword
    self.table_name = 'keywords'
    self.abstract_class = true
    attr_accessible :vendor, :account

    def response_text
      # we ask for new_record in order to avoid save ordering problems
      # sometimes the account or vendor are not set yet
      read_attribute(:response_text) || default_response_text unless new_record?
    end

    def name=(n)
      write_attribute(:name, n) #leave uppercase
    end

    def special?
      true
    end
  end

  class VendorStop < SpecialKeyword

    def execute_commands(command_parameters)
      vendor.stop!(command_parameters)
    end

    def default_response_text
      vendor.stop_text
    end
  end

  class VendorHelp < SpecialKeyword

    def execute_commands(command_parameters)
      #noop
      Rails.logger.info("HelpKeyword: #{command_parameters}" )
    end

    def default_response_text
      vendor.try(:help_text) # respond_directly
    end
  end

  class VendorDefault < SpecialKeyword

    def default_response_text
      #can be nil if a command is meant to respond
      vendor.default_response_text  #utimate passthrough
    end

    def default?
      true
    end
  end

  class AccountStop < SpecialKeyword

    def execute_commands(command_parameters)
      account.stop!(command_parameters)
    end

    def default_response_text
      account.stop_text
    end
  end

  class AccountHelp < SpecialKeyword

    def execute_commands(command_parameters)
      #noop
      Rails.logger.info("HelpKeyword: #{command_parameters}" )
    end

    def default_response_text
      account.help_text # respond_directly
    end
  end

  class AccountDefault < SpecialKeyword

    def default_response_text
      account.default_response_text #can be nil if a command is meant to respond asynchronously
    end

    def default?
      true
    end

  end

end
