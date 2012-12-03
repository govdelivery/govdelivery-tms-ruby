InboundSmsParser = Struct.new(:text) do
  def dispatch!(h)
    if stop?
      h['stop'].call
    elsif callable = h[text.downcase.strip]
      callable.call
    else
      h['help'].call
    end
  end

  private

  def stop?
    # the first word in the message is either stop or quit
    !!(text =~ /^\s*(stop|quit)(\s|$)/i)
  end
end
