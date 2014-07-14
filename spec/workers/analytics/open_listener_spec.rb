require 'spec_helper'
describe Analytics::OpenListener do
  subject { Analytics::OpenListener.new.wrapped_object }

  it 'should have channel' do
    expect(subject.channel).to eq('open_channel')
  end

  it 'should respond to a message' do
    message   = {}
    partition = 1
    offset    = 1_000
    subject.on_message(message, partition, offset)
  end
end