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
    Keyword.stop?(text)
  end
end
