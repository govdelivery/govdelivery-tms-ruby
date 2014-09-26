require 'rails_helper'
describe Messages::CheckMessageForCompletion do

  subject { Messages::CheckMessageForCompletion.new }

  it 'should work on a message' do
    message=mock('message', :completed? => false, :complete! => false, id: 7)

    SmsMessage.expects(:without_message).returns(mock('scope', find: message))

    subject.perform('message_class' => 'SmsMessage', 'message_id' => 7)
  end

  it 'should silently exit if message is already complete' do
    message=mock('message', :completed? => true)

    SmsMessage.expects(:without_message).returns(mock('scope', find: message))

    subject.perform('message_class' => 'SmsMessage', 'message_id' => 7)
  end
end
