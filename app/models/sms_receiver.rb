SmsReceiver = Struct.new(:vendor, :stop_text, :help_text) do
  attr_writer :keywords, :parser

  # === Arguments
  #
  # +params+ - A CommandParameter instance
  #
  def respond_to_sms!(params)
    parser.call(params.sms_body, command_dispatch_hash(params))
  end

  private

  def command_dispatch_hash(params)
    keywords.reduce({
                      'stop' => -> { do_stop(params) },
                      'help' => -> { do_help(params) }
                    }) { |memo, keyword| memo.merge!(keyword.name => on_keyword(params, keyword)) }
  end

  def on_keyword(params, keyword)
    ->(*args) do
      execute_keyword_commands(params, keyword, args)
      keyword.response_text
    end
  end

  def do_stop(params)
    vendor.receive_message!(:from => params.from, :to => params.to, :body => params.sms_body, :stop? => true, :keyword_response => stop_text)
    stop_text
  end

  def execute_keyword_commands(params, keyword, sms_tokens)
    params.sms_tokens = sms_tokens
    inbound_msg = vendor.receive_message!(:from => params.from, :to => params.to, :body => params.sms_body, :stop? => false, :keyword => keyword)
    params.inbound_message_id = inbound_msg.id
    keyword.execute_commands(params)
  end

  def do_help(params)
    vendor.receive_message!(:to => params.to, :from => params.from, :body => params.sms_body, :stop? => false, :keyword_response => help_text)
    help_text
  end

  # sane defaults!
  def keywords
    @keywords ||= []
  end

  def parser
    @parser ||= lambda { |body, dispatch|
      p = InboundSmsParser.new(body)
      p.dispatch!(dispatch)
    }
  end
end
