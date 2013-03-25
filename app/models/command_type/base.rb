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

    def invoke!(params)
      "#{self.class.name.demodulize}Worker".constantize.perform_async(params.to_hash)
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
      ca = CommandAction.find_or_initialize_by_inbound_message_id_and_command_id(
        inbound_message_id: params.inbound_message_id,
        command_id: params.command_id,
        status: http_response.status,
        content_type: http_response.headers['Content-Type'],
        response_body: http_response.body)
      ca.save!
      ca
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