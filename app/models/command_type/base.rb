module CommandType
  class Base
    attr_accessor :string_fields, :array_fields

    alias :required_string_fields :string_fields
    alias :required_array_fields :array_fields

    def initialize(string_fields, array_fields)
      self.string_fields = string_fields
      self.array_fields = array_fields
    end

    def name
      self.class.name.demodulize.underscore.to_sym
    end

    # new object of this type will call :process_response in the background
    def perform_async!(params)
      "#{self.class.name.demodulize}Worker".constantize.perform_async(params.to_hash)
    end

    # this will get called in the background
    def process_response(account, params, http_response)
      save_command_action!(params, http_response)
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

    def save_command_action!(params, http_response)
      CommandAction.where(
        inbound_message_id: params.inbound_message_id,
        command_id: params.command_id).
        first_or_create!(
        status: http_response.status,
        content_type: http_response.headers['Content-Type'],
        response_body: http_response.body)
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
