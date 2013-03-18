module CommandType
  class Forward < Base
    STRING_FIELDS = [:http_method, :username, :password, :url].freeze

    def initialize
      super(STRING_FIELDS.dup, [])
    end

    def process_response(account, params, http_response)
      cr = CommandAction.create!(inbound_message_id: params.inbound_message_id,
                                   command_id: params.command_id,
                                   http_response_code: http_response.code,
                                   http_response_type: http_response.headers['Content-Type'],
                                   http_body: body(http_response.body))
      build_message(account, params.from, http_response.body.strip) if cr.http_content_type=='text/plain'
    end

    def body(_body)
      _body.length > 500 ? nil : _body.strip
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