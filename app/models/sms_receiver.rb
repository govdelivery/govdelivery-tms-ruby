SmsReceiver = Struct.new(:vendor, :command_parameters) do
  attr_writer :parser, :inbound_sms_context
  delegate :stop_text, :help_text, :stop_action, :keywords, :body_without_prefix, to: :inbound_sms_context

  # === Arguments
  #
  # +command_parameters+ - A CommandParameter instance
  #
  def respond_to_sms!
    parser.call(command_parameters.sms_body, command_dispatch_hash)
  end

  def inbound_sms_context
    @inbound_sms_context ||= InboundSmsContext.new(vendor, command_parameters.sms_body)
  end

  private

  ##
  # combine all elements of 'keywords' into a single hash
  # where the keys are keyword names and the values are
  # keyword procs that can be called.
  #
  def command_dispatch_hash
    keywords.reduce(stop_and_help) do |memo, keyword| 
      # memo is the keyword hash {keyword.name => keyword_proc}
      memo.merge!(keyword.name => on_keyword(command_parameters, keyword))
    end
  end

  def stop_and_help
    {
      'stop' => -> { record_inbound_message!(command_parameters, keyword_response: stop_text) { stop_action.call(command_parameters) } },
      'help' => -> { record_inbound_message!(command_parameters, keyword_response: help_text) }
    }
  end

  ##
  # Return a proc encapsulating the action that needs to be taken
  # when the keyword has been matched
  #
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
      p = InboundSmsParser.new(body_without_prefix)
      p.dispatch!(dispatch)
    }
  end

  def record_inbound_message!(params, attributes={})
    inbound_msg = vendor.receive_message!({from: params.from, to: params.to, body: params.sms_body}.merge!(attributes))
    unless inbound_msg.ignored? # a simple throttle check
      params.inbound_message_id = inbound_msg.id
      yield if block_given?
      inbound_msg.keyword_response
    end
  end
end
