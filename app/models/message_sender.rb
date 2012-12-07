MessageSender = Struct.new(:from, :send_proc) do
  def send!(recipients)
    recipients.each do |r|
      result = send_proc.call(from, r.formatted_phone)
      r.complete!(result[:status], result[:ack])
    end
  end
end
