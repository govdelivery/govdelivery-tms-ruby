module CommandType
  class Forward < Base
    STRING_FIELDS = [
                      :from_param_name,
                      :http_method, 
                      :password, 
                      :sms_body_param_name,
                      :url,
                      :username
                    ].freeze

    def initialize
      super(STRING_FIELDS.dup, [])
    end

    def required_string_fields
      [:http_method, :url, :sms_body_param_name, :from_param_name]
    end

    def process_response(account, params, http_response)
      cr = super
      build_message(account, params.from, cr.response_body) if cr.plaintext_body?
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