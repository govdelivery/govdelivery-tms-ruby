require 'spec_helper'
describe CreateRecipientsWorker do
  let(:worker) { CreateRecipientsWorker.new }
  let(:recipient_params) { stub('recipients') }
  let(:send_worker) { mock('LoopbackMessageWorker', :perform_async => true) }

  it 'should enqueue a message worker job if there are recipients' do
    message = mock('message', :worker => send_worker)
    message.stubs(:id).returns(1)
    message.expects(:create_recipients).with(recipient_params)
    SmsMessage.expects(:find).with(1).returns(message)

    worker.perform('message_id' => 1, 'send_options' => {}, 'recipients' => recipient_params, 'klass'=>'SmsMessage')
  end

  it 'should complete if there are no recipients' do
    message = mock('message')
    message.stubs(:id).returns(1)
    message.expects(:check_complete!)
    VoiceMessage.expects(:find).with(1).returns(message)

    worker.perform('message_id' => 1, 'ssend_options' => {}, 'recipients' => {}, 'klass'=>'VoiceMessage')
  end

end