InboundSmsParser = Struct.new(:text) do
  def dispatch!(h)
    if stop?
      h['stop'].call
    elsif callable = h[first_token]
      callable.call(*tokens[1..-1])
    else
      h['help'].call
    end
  end

  private

  def tokens
    @tokens ||= text.strip.split(/\s+/)
  end

  def first_token
    (tokens[0] || '').downcase.strip
  end

  def stop?
    # for at least one of our vendors (twilio) we need to support 
    # stop, quit, cancel, and unsubscribe
    # http://www.twilio.com/help/faq/sms/does-twilio-support-stop-block-and-cancel-aka-sms-filtering
    # the first word in the message is either stop or quit
    !!(text =~ /^\s*(stop|quit|cancel|unsubscribe)(\s|$)/i)
  end
end
