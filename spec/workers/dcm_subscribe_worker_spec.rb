require 'spec_helper'
describe DcmSubscribeWorker do
  let(:phone_number) { '+14443332222' }
  let(:data_string) { 'ACCOUNT_CODE:TOPIC_CODE,TOPIC_2' }
  let(:subscribe_action) { mock('dcm_subscribe_action') }

  before do
    config = {:username => "foo", :password => "bar", :api_root => "http://example.com"}
    client = mock('dcm_client')
    Tsms::Application.config.expects(:dcm).returns(config)
    DCMClient::Client.expects(:new).with(config).returns(client)
    DcmSubscribeAction.expects(:new).with(client).returns(subscribe_action)
  end

  it 'passes options to the subscribe action' do
    subscribe_action.expects(:call).with(phone_number, data_string)

    subject.perform({:params => data_string, :from => phone_number})
  end

  it 'ignores UnprocessableEntity errors' do
    subscribe_action.expects(:call)
      .with(phone_number, data_string) 
      .raises(DCMClient::Error::UnprocessableEntity.new("foo"))

    subject.perform({:params => data_string, :from => phone_number})
  end 
end

