require 'spec_helper'
describe TwilioMessageWorker do
  let(:vendor) { create_sms_vendor(:worker => 'TwilioVoiceWorker') }
  let(:account) { vendor.accounts.create!(:name => 'name') }
  let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:message) { stub('SmsMessage', :vendor=>vendor, :id=>1) }

  describe 'a happy or sad send' do
    let(:worker) { TwilioMessageWorker.new }

    it 'should work' do
      SmsMessage.expects(:find_by_id).with(message.id).returns(message)

      klass = Service::TwilioSmsMessageService
      service = mock('Service::TwilioSmsMessageService')
      service.expects(:deliver!).with(message, 'callback_url').returns(true)
      klass.expects(:new).with(vendor.username, vendor.password).returns(service)
      worker.perform('callback_url' => 'callback_url', 'message_id' => message.id)
    end
  end
end