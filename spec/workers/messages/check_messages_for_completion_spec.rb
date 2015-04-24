require 'rails_helper'
describe Messages::CheckMessagesForCompletion do
  subject {Messages::CheckMessagesForCompletion.new}

  it 'should use the sending scope of each channel and check the messages for completion' do
    classes =  sequence('classes')
    Messages::CheckMessageForCompletion.expects(:perform_async).with(message_class: 'SmsMessage', message_id: 7).in_sequence(classes)
    Messages::CheckMessageForCompletion.expects(:perform_async).with(message_class: 'VoiceMessage', message_id: 7).in_sequence(classes)
    Messages::CheckMessageForCompletion.expects(:perform_async).with(message_class: 'EmailMessage', message_id: 7).in_sequence(classes)

    @msg_stub = stub('message', class: SmsMessage, id: 7)
    @sending  = stub('message_scope')
    @sending.expects(:find_each).times(3).yields(@msg_stub)

    subject.stubs(:message_scope).returns(@sending)

    subject.perform
  end
end
