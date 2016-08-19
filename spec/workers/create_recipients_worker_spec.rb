require 'rails_helper'
describe CreateRecipientsWorker do
  let(:worker) {CreateRecipientsWorker.new}
  let(:recipient_params) {stub('recipients')}
  let(:send_worker) {mock('LoopbackMessageWorker', perform_async: true)}

  it 'should enqueue a message worker job if there are recipients' do
    message = mock('message', worker: send_worker)
    message.stubs(:id).returns(1)
    message.expects(:ready!).with(recipient_params)
    SmsMessage.expects(:find).with(1).returns(message)

    worker.perform('message_id' => 1, 'send_options' => {}, 'recipients' => recipient_params, 'klass' => 'SmsMessage')
    expect(worker.class.get_sidekiq_options['queue']).to eq(:recipient)
  end

  it 'should complete if there are no recipients' do
    message = mock('message')
    message.stubs(:id).returns(1)
    message.expects(:ready!).with({}).raises(AASM::InvalidTransition)
    message.expects(:complete!).returns(true)
    VoiceMessage.expects(:find).with(1).returns(message)

    worker.perform('message_id' => 1, 'send_options' => {}, 'recipients' => {}, 'klass' => 'VoiceMessage')
  end

  it 'should fail the job if ready and complete transitions are invalid' do
    message = mock('message')
    message.stubs(:id).returns(1)
    message.expects(:ready!).with({}).raises(AASM::InvalidTransition)
    message.expects(:complete!).returns(false)
    EmailMessage.expects(:find).with(1).returns(message)

    expect {worker.perform('message_id' => 1, 'send_options' => {}, 'recipients' => {}, 'klass' => 'EmailMessage')}.to raise_error(Sidekiq::Retries::Fail)
  end
end
