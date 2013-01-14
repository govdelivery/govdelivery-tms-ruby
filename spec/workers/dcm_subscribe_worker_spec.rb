require 'spec_helper'
describe DcmSubscribeWorker do
  let(:phone_number) { '+14443332222' }
  let(:account_code) { 'ACCOUNT_CODE' }
  let(:topic_codes) { ['TOPIC_CODE','TOPIC_2'] }
  let(:subscribe_args) { ['foo@bar.com'] }
  let(:subscribe_command) { mock('dcm_subscribe_command') }

  before do
    config = {:username => "foo", :password => "bar", :api_root => "http://example.com"}
    client = mock('dcm_client')
    Tsms::Application.config.expects(:dcm).returns(config)
    DCMClient::Client.expects(:new).with(config).returns(client)
    DcmSubscribeCommand.expects(:new).with(client).returns(subscribe_command)
  end

  it 'passes options to the subscribe command' do
    subscribe_command.expects(:call).with(phone_number, account_code, topic_codes, subscribe_args)

    subject.perform({:dcm_account_code => account_code, :from => phone_number, :dcm_topic_codes => topic_codes, :sms_tokens => subscribe_args})
  end

  it 'ignores UnprocessableEntity errors' do
    subscribe_command.expects(:call)
      .with(phone_number, account_code, topic_codes, subscribe_args) 
      .raises(DCMClient::Error::UnprocessableEntity.new("foo"))

    subject.perform({:dcm_account_code => account_code, :from => phone_number, :dcm_topic_codes => topic_codes, :sms_tokens => subscribe_args})
  end 
end
