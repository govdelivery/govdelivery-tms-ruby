require 'rails_helper'
describe Messages::CheckMessageForCompletion do
  subject { Messages::CheckMessageForCompletion.new }

  it 'should work on a message' do
    message = mock('message', completed?: false, complete!: false, id: 7)
    lock   = mock('lock', without_message: mock('scope', find: message))
    SmsMessage.expects(:lock).returns(lock)

    subject.perform('message_class' => 'SmsMessage', 'message_id' => 7)
  end

  it 'should silently exit if message is already complete' do
    message = mock('message', completed?: true)
    lock   = mock('lock', without_message: mock('scope', find: message))
    SmsMessage.expects(:lock).returns(lock)

    subject.perform('message_class' => 'SmsMessage', 'message_id' => 7)
  end

  it 'should silently exit if record is locked' do
    SmsMessage.expects(:lock).raises(ActiveRecord::RecordNotFound)
    expect(subject.perform('message_class' => 'SmsMessage', 'message_id' => 7)).to be false
  end
end
