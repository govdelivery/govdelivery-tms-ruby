module CommandType
  class Forward < Base
    STRING_FIELDS = [
                      :from_param_name,
                      :http_method,
                      :password,
                      :sms_body_param_name,
                      :strip_keyword,
                      :url,
                      :expected_content_type,
                      :username
                    ].freeze

    def initialize
      super(STRING_FIELDS.dup, [])
    end

    def required_string_fields
      [:http_method, :url, :sms_body_param_name, :from_param_name, :expected_content_type]
    end

    # this will get called in the background
    def process_response(account, params, http_response)
      command_action = super
      # check content type against expected to prevent garbage from going to user
      if command_action.content_type.include?(params.expected_content_type) && command_action.success?
        build_message(account, params.from, command_action.response_body)
      else
        Rails.logger.warn "ignoring: #{command_action.inspect}"
        return nil
      end
    end

    def build_message(account, from, short_body)
      # User is out of context for this message, as there is no current user - the
      # incoming controller request was from a handset (not a client's app)
      message = account.sms_messages.new(body: short_body)
      message.recipients.build(phone: from, vendor: account.sms_vendor)
      message.save!
      message
    end

  end
end
