SmsReceiver = Struct.new(:vendor, :stop_text, :help_text) do
  attr_writer :keywords, :parser

  def respond_to_sms!(from, body)
    inbound_sms = parser.call(body, action_dispatch_hash(from, body))
  end

  private

  def action_dispatch_hash(from, body)
    keywords.reduce({
      'stop' => ->{do_stop(from, body)},
      'help' => ->{do_help(from, body)}
    }) { |memo, kw| memo.merge!(kw.name => ->(*args){ do_keyword(from, body, kw, args)}) }
  end

  def do_stop(from, body)
    vendor.receive_message!(:from => from, :body => body, :stop? => true)
    stop_text
  end

  def do_keyword(from, body, kw, args)
    vendor.receive_message!(:from => from, :body => body, :stop? => false)
    kw.execute_actions(:from => from, :args => args)
    nil
  end

  def do_help(from, body)
    vendor.receive_message!(:from => from, :body => body, :stop? => false)
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
