module CommandType
  class Base
    attr_accessor :string_fields, :array_fields

    def initialize(string_fields, array_fields)
      self.string_fields = string_fields
      self.array_fields = array_fields
    end

    def name
      self.class.name.demodulize.underscore.to_sym
    end

    def invoke!(params)
      "#{CommandType::DcmSubscribe.name.demodulize}Worker".constantize.perform_async(params.to_hash)
    end

    def process_response(account, params, http_response)
      log_action!(params, http_response)
    end

    def all_fields
      string_fields + array_fields
    end

    def validate_params(command_params, account)
      command_params = CommandParameters.new(command_params) unless command_params.is_a?(CommandParameters)
      command_params.command_type = self
      command_params.account = account
      command_params.valid?
      command_params.errors
    end

    protected

    def log_action!(params, http_response)
      CommandAction.create!(inbound_message_id: params.inbound_message_id,
                            command_id: params.command_id,
                            http_response_code: http_response[:status],
                            http_content_type: http_response[:headers]['Content-Type'],
                            http_body: http_response[:body])
    end
  end

  ALL = HashWithIndifferentAccess.new

  def self.[](command_type)
    ALL[command_type] ||= self.const_get(command_type.to_s.classify).new
  end

  def self.all
    ALL
  end
end

CommandType[:dcm_subscribe]
CommandType[:dcm_unsubscribe]
CommandType[:forward]