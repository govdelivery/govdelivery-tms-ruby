require 'rails_helper'
describe Analytics::BounceListener do
  subject { Analytics::BounceListener.new }

  it 'should have topic' do
    expect(subject.topic).to eq('tms_bounce_channel')
  end

  it 'should have group' do
    expect(subject.group).to eq('xact.bounce_listener')
  end

  it 'should hand messages off to sidekiq' do
    message = {'recipient' => 'fake',
               'uri'       => 'bounce',
               'message'   => 'blows'}
    Analytics::ProcessBounce.expects(:perform_async).with(message)
    subject.on_message(message, 1, 1_000)
  end
end
