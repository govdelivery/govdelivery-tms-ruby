MessageSender = Struct.new(:from) do
  def send!(recipients, send_proc)
    recipients.each do |r|
      result = send_proc.call(from, r.formatted_phone)
      r.complete!(result[:status], result[:ack])
    end
  end
end
