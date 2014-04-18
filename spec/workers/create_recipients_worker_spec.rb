require 'spec_helper'
describe CreateRecipientsWorker do
  let(:worker) { CreateRecipientsWorker.new }
  let(:recipient_params) { stub('recipients') }
  let(:send_worker) { stub('LoopbackMessageWorker') }
  let(:message) { stub('message', id: 1, worker: send_worker, attributes: {}) }

  it 'should enqueue a message worker job if there are recipients' do
    send_worker.expects(:perform_async)
    message.expects(:create_recipients).with(recipient_params)
    SmsMessage.expects(:find).with(1).returns(message)

    worker.perform('message_id' => 1, 'send_options' => {}, 'recipients' => recipient_params, 'klass'=>'SmsMessage')
  end

  it 'should complete if there are no recipients' do
    message.expects(:check_complete!)
    VoiceMessage.expects(:find).with(1).returns(message)

    worker.perform('message_id' => 1, 'ssend_options' => {}, 'recipients' => {}, 'klass'=>'VoiceMessage')
  end

  describe 'throttling' do
    it "shouldn't throttle messages that don't match any conditions" do
      worker.stubs(:get_attrs).returns([])
      Odm::ThrottledTmsExtendedSenderWorker.expects(:perform_async).never

      send_worker.expects(:perform_async)
      message.expects(:create_recipients).with(recipient_params)
      EmailMessage.expects(:find).with(1).returns(message)

      worker.perform('message_id' => 1, 'send_options' => {}, 'recipients' => recipient_params, 'klass'=>'EmailMessage')
    end

    it 'should throttle some messages' do
      worker.stubs(:get_attrs).returns([{subject: 'Please throttle me!'}])
      Odm::ThrottledTmsExtendedSenderWorker.expects(:perform_async)

      send_worker.expects(:perform_async).never
      message.stubs(:attributes).returns(subject: 'Please throttle me!')
      message.expects(:create_recipients).with(recipient_params)
      EmailMessage.expects(:find).with(1).returns(message)

      worker.perform('message_id' => 1, 'send_options' => {}, 'recipients' => recipient_params, 'klass'=>'EmailMessage')
    end
  end
end
