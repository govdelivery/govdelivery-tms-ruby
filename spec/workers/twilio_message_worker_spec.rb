require 'spec_helper'
describe TwilioMessageWorker do
  let(:sms_vendor) { create(:sms_vendor, :worker => 'TwilioMessageWorker') }
  let(:account) { account = sms_vendor.accounts.create!(:name => 'name') }
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:message) { account.sms_messages.create!(:body => 'hello, message worker!', :recipients_attributes => [{:phone => "5554443333", :vendor => sms_vendor}]) }

  #need to add recipient stubs and verify recipients are modified correctly
  context 'a very happy send' do
    it 'should work' do
      twilio_sms_messages = mock
      twilio_sms_messages.expects(:create).returns(OpenStruct.new(:sid => 'abc123', :status => 'completed'))
      Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(OpenStruct.new(:account => OpenStruct.new(:sms => OpenStruct.new(:messages => twilio_sms_messages))))
      expect { subject.perform(:message_id => message.id) }.to change { message.recipients.where(:ack => 'abc123').count }.by 1
    end
  end

  context 'a sad send' do
    it 'should not work' do
      twilio_sms_messages = mock
      twilio_sms_messages.expects(:create).raises(Twilio::REST::RequestError.new('error'))
      Twilio::REST::Client.expects(:new).with(message.vendor.username, message.vendor.password).returns(OpenStruct.new(:account => OpenStruct.new(:sms => OpenStruct.new(:messages => twilio_sms_messages))))
      expect { subject.perform(:message_id => message.id) }.to change { message.recipients.where(:error_message => 'error').count }.by 1
    end
  end
end
