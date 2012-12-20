SmsReceiver = Struct.new(:vendor, :stop_text, :help_text) do
  attr_writer :keywords, :parser

  def respond_to_sms!(action_parameters)
    inbound_sms = parser.call(action_parameters.sms_body, action_dispatch_hash(action_parameters))
  end

  private

  def action_dispatch_hash(action_parameters)
    keywords.reduce({
      'stop' => ->{do_stop(action_parameters)},
      'help' => ->{do_help(action_parameters)}
    }) { |memo, keyword| memo.merge!(keyword.name => on_keyword(action_parameters, keyword)) }
  end

  def on_keyword(action_parameters, keyword)
    ->(*args) do 
      execute_keyword_actions(action_parameters, keyword, args)
    end
  end

  def do_stop(action_parameters)
    vendor.receive_message!(:from => action_parameters.from, :body => action_parameters.sms_body, :stop? => true)
    stop_text
  end

  def execute_keyword_actions(action_parameters, keyword, sms_tokens)
    action_parameters.sms_tokens = sms_tokens
    vendor.receive_message!(:from => action_parameters.from, :body => action_parameters.sms_body, :stop? => false)
    keyword.execute_actions(action_parameters)
    nil
  end

  def do_help(action_parameters)
    vendor.receive_message!(:from => action_parameters.from, :body => action_parameters.sms_body, :stop? => false)
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
