require 'rails_helper'
describe CheckMessagesForCompletion do

  it 'should use the sending scope of each channel and check the messages for completion' do
    pending('why is this pending?')
    @msg_stub = stub('Message', id: 100)
    @msg_stub.expects(:check_complete!).times(3)

    @sending = stub('sending')
    @sending.expects(:find_each).times(3).yields(@msg_stub)

    [SmsMessage, VoiceMessage, EmailMessage].each do |message_class|
      message_class.expects(:sending).returns(@sending)
    end

    CheckMessagesForCompletion.new.perform
  end
end
