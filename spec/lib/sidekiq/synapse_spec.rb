require 'rails_helper'

describe 'Sidekiq::Synapse' do

  context 'bounce listener' do
    subject { Sidekiq::Synapse::BOUNCE_LISTENER.instance }
    let(:message) {
      msg = stub('message')
      msg.stubs(:to_hash).returns(msg)
      msg
    }
    it 'should handle bounces' do
      expect(subject.topic).to eq(:tms_bounce_channel)
      expect(subject.group).to eq(:'xact.bounce_listener')
      Analytics::ProcessBounce.expects(:perform_async).with(message)
      subject.handleMessage(1, 2, nil, message)
    end
  end

  context 'kahlo listener' do
    subject { Sidekiq::Synapse::KAHLO_LISTENER.instance }
    let(:message) {
      msg = stub('message', :[] => 'xact')
      msg.stubs(:to_hash).returns(msg)
      msg
    }
    it 'should handle bounces' do
      expect(subject.group).to eq(:'xact-kahlo_message_statuses')
      Kahlo::StatusWorker.expects(:perform_async).with(message)
      subject.handleMessage(1, 2, nil, message)
    end
  end

end
