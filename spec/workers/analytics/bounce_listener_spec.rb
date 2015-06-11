require 'rails_helper'
describe Analytics::BounceListener do
  subject { Analytics::BounceListener.new }
  let(:message) {
    {'recipient' => 'fake',
     'uri'       => 'bounce',
     'message'   => 'blows'}
  }
  let(:java_map) { java.util.HashMap.new(message) }

  it 'should have topic' do
    expect(subject.topic).to eq('tms_bounce_channel')
  end

  it 'should have group' do
    expect(subject.group).to eq('xact.bounce_listener')
  end

  it 'should hand messages off to sidekiq' do
    Analytics::ProcessBounce.expects(:perform_async).with(message)
    subject.on_message(java_map, 1, 1_000)
  end
end
