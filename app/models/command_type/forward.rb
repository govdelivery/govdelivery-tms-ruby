module CommandType
  class Forward < Base
    STRING_FIELDS = [:http_method, :username, :password, :url].freeze

    def initialize
      super(STRING_FIELDS.dup, [])
    end

    def process_response(account, params, http_response)
      cr = super
      build_message(account, params.from, cr.http_body) if cr.plaintext_body?
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