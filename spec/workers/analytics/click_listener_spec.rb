require 'spec_helper'
describe Analytics::ClickListener do
  subject { Analytics::ClickListener.new.wrapped_object }

  it 'should have channel' do
    expect(subject.channel).to eq('click_channel')
  end

  it 'should have group_id' do
    expect(subject.group_id).to eq('xact.click_listener')
  end

  it 'should respond to a message' do
    message   = {}
    partition = 1
    offset    = 1_000
    subject.on_message(message, partition, offset)
  end
end