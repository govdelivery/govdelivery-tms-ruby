InboundSmsParser = Struct.new(:text) do
  def dispatch!(h)
    
    if stop?
      h['stop'].call

    # if the first token in the sms matches this callable's keyword...
    elsif callable = h[first_token]
      callable.call(*tokens[1..-1])
    
    # we didn't recognize anything (or the text was 'help')
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
    Keyword.stop?(text)
  end
end
