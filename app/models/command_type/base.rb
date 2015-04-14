module CommandType
  class Base
    attr_accessor :string_fields, :array_fields

    alias_method :required_string_fields, :string_fields
    alias_method :required_array_fields, :array_fields

    def initialize(string_fields, array_fields)
      self.string_fields = string_fields
      self.array_fields  = array_fields
    end

    def name
      self.class.name.demodulize.underscore.to_sym
    end

    # new object of this type will call :process_response in the background
    def perform_async!(params)
      "CommandWorkers::#{self.class.name.demodulize}Worker".constantize.perform_async(params.to_hash)
    end

    # this will get called in the background
    def process_response(_account, params, http_response)
      content_type = http_response.try(:headers).try(:[], 'Content-Type')
      command_action(params).tap do |action|
        action.update!(
          status:        http_response.status,
          content_type:  content_type,
          response_body: response_body(http_response.body),
          error_message: nil
        )
      end
    end

    def process_error(params, error_message)
      command_action(params).update!(
        status:        nil,
        content_type:  nil,
        response_body: nil,
        error_message: error_message
      )
    end

    def all_fields
      string_fields + array_fields
    end

    def validate_params(command_params, account)
      command_params              = CommandParameters.new(command_params) unless command_params.is_a?(CommandParameters)
      command_params.command_type = self
      command_params.account      = account
      command_params.valid?
      command_params.errors
    end

    protected

    def command_action(params)
      CommandAction.where(
        inbound_message_id: params.inbound_message_id,
        command_id:         params.command_id)
        .first_or_initialize
    end

    # DCM command type responses return parsed hashes of JSON, so...
    def response_body(body)
      case
      when body.is_a?(String)
        body
      when body.nil?
        nil
      when body.respond_to?(:to_json)
        body.to_json
      end
    end
  end

  ALL = HashWithIndifferentAccess.new unless defined?(ALL)

  def self.[](command_type)
    ALL[command_type] ||= const_get(command_type.to_s.classify).new
  end

  def self.all
    ALL
  end
end

CommandType[:dcm_subscribe]
CommandType[:dcm_unsubscribe]
CommandType[:forward]
