require 'rails_helper'
describe Analytics::OpenListener do
  subject { Analytics::OpenListener.new }

  it 'should have topic' do
    expect(subject.topic).to eq('open_channel')
  end

  it 'should have group' do
    expect(subject.group).to eq('xact.open_listener')
  end

  it 'should respond to a message' do
    message   = {}
    partition = 1
    offset    = 1_000
    subject.on_message(message, partition, offset)
  end
end
