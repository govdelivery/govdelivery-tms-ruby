require_relative '../../app/models/message_sender'
require_relative '../little_spec_helper'
require 'ostruct'

describe MessageSender do
  describe "#send!" do
    let(:to) { 'blah' }
    let(:from) { 'hello' }

    it "should send a message to one recipient" do
      ms = MessageSender.new(from)
      ms.send!([recipient_expectation], send_proc_expectation)
    end

    it "should send a message to multiple recipients" do
      recipient = recipient_expectation(2)
      ms = MessageSender.new(from)
      ms.send!([recipient, recipient], send_proc_expectation(2))
    end
  end

  def recipient_expectation(times=1)
    recipient = OpenStruct.new(:formatted_phone => to)
    recipient.expects(:complete!).with("good", "ackkkk").times(times)
    recipient
  end

  def send_proc_expectation(times=1)
    send_proc = mock()
    send_proc.expects(:call).with(from,to).times(times).returns({:ack => 'ackkkk', :status => "good"})
    send_proc
  end

end