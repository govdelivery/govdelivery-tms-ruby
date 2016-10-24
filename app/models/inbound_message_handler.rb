class InboundMessageHandler

  attr_accessor :vendor
  attr_reader :vendor_scope

  def initialize(vendor_scope = SmsVendor)
    @vendor_scope = vendor_scope
  end

  # returns true if the message should be responded to
  def handle(sid, to, from, body)
    self.vendor         ||= vendor_scope.find_by_from_phone!(to)
    @command_parameters = CommandParameters.new(sms_body: body, to: to, from: from)

    # parse it
    _prefix,
      keyword_service,
      message,
      account_id        = InboundSmsParser.parse(body, vendor)

    # store it
    @inbound_message    = vendor.create_inbound_message!(
      from:             @command_parameters.from,
      to:               @command_parameters.to,
      body:             @command_parameters.sms_body,
      vendor_sid:       sid,
      account_id:       account_id, # used for scoped reporting, can be blank
      keyword:          keyword_service.keyword,
      keyword_response: keyword_service.response_text)

    # we don't respond inline to "ignored" messages,
    # but keyword commands still execute and could cause messages to be sent
    @command_parameters.merge!(sms_tokens: message.split, inbound_message_id: @inbound_message.id)
    @response_text = keyword_service.respond!(@command_parameters)

    ForwardStopsToDcm.verify_and_forward!(@command_parameters.sms_body, @command_parameters.to, @command_parameters.from, sid, vendor.username)

    if @inbound_message.ignored?
      Rails.logger.info "Ignoring InboundMessage #{@inbound_message.id}"
      false
    else
      true
    end
  end

  # from number for response
  def from
    vendor.from
  end

  # who to send response to
  def to
    @command_parameters.from
  end

  # callback id for response (required for kahlo)
  def callback_id
    @inbound_message.callback_id
  end

  # response body
  attr_reader :response_text

end