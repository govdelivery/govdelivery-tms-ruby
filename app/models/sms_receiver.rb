SmsReceiver = Struct.new(:vendor) do
  attr_writer :parser
  delegate :stop_text, :help_text, :keywords, to: :vendor

  # === Arguments
  #
  # +params+ - A CommandParameter instance
  #
  def respond_to_sms!(command_parameters)
    parser.call(command_parameters.sms_body, command_dispatch_hash(command_parameters))
  end

  private

  def command_dispatch_hash(params)
    keywords.reduce({
                      'stop' => -> { record_inbound_message!(params, keyword_response: stop_text) { vendor.stop!(params) } },
                      'help' => -> { record_inbound_message!(params, keyword_response: help_text) }
                    }) { |memo, keyword| memo.merge!(keyword.name => on_keyword(params, keyword)) }
  end

  def on_keyword(params, keyword)
    ->(*args) do
      params.sms_tokens = args
      record_inbound_message!(params, keyword: keyword) do
        keyword.execute_commands(params)
      end
    end
  end

  def parser
    @parser ||= lambda { |body, dispatch|
      p = InboundSmsParser.new(body)
      p.dispatch!(dispatch)
    }
  end

  def record_inbound_message!(params, attributes={})
    inbound_msg = vendor.receive_message!({from: params.from, to: params.to, body: params.sms_body}.merge!(attributes))
    params.inbound_message_id = inbound_msg.id
    yield if block_given?
    inbound_msg.keyword_response
  end
end
