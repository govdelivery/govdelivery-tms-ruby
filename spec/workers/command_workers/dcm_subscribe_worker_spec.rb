require 'rails_helper'
describe CommandWorkers::DcmSubscribeWorker do
  let(:phone_number) { '+14443332222' }
  let(:account_code) { 'ACCOUNT_CODE' }
  let(:topic_codes) { ['TOPIC_CODE', 'TOPIC_2'] }
  let(:subscribe_args) { ['foo@bar.com'] }
  let(:client) { mock('dcm_client') }

  let(:account) { create(:account) }
  let(:command) do
    create(:dcm_subscribe_command,
           keyword: account.stop_keyword,
           params:  build(:subscribe_command_parameters))
  end

  let(:http_response) do
    stub('http_response',
         status:  200,
         headers: {'Content-Type' => 'andrew/json'},
         body:    'foo')
  end

  let(:http_404_response) do
    stub('http_response_404',
         status:  404,
         headers: {'Content-Type' => 'andrew/json'},
         body:    'nope')
  end

  let(:http_failure_response) do
    stub('http_response_422',
         status:  422,
         headers: {'Content-Type' => 'andrew/json'},
         body:    'error: you suck')
  end

  let(:options) do
    {
      from:               "+12222222222",
      inbound_message_id: create(:inbound_message).id,
      command_id:         command.id
    }
  end

  let(:command_parameters){
    build(:subscribe_command_parameters)
  }

  subject do
    CommandWorkers::DcmSubscribeWorker.new
  end

  context 'error handling' do

    it 'passes options to the subscribe command' do
      DCMClient::Client.any_instance.expects(:wireless_subscribe).with('1+651888888', command_parameters.dcm_account_code, command_parameters.dcm_topic_codes).returns(http_response)
      subject.perform(options.merge(from: '+1651888888'))
    end

    it 'ignores 422s' do
      subject.expects(:request_subscription).raises(DCMClient::Error::UnprocessableEntity.new("foo", http_failure_response))
      expect { subject.perform(options.merge(from: '+1651888888')) }.to_not raise_error
    end

    it 'ignores 404s' do
      subject.expects(:request_subscription).raises(DCMClient::Error::NotFound.new("foo", http_404_response))
      expect { subject.perform(options) }.to_not raise_error
    end

    it 'raises other dcm client errors' do
      subject.expects(:request_subscription).raises(DCMClient::Error.new('hi'))
      expect { subject.perform(options) }.to raise_error(DCMClient::Error)
    end

    it 'raises other exceptions' do
      subject.expects(:request_subscription).raises(StandardError.new('hi'))
      expect { subject.perform(options) }.to raise_error(StandardError)
    end
  end

  context 'multiple requests' do
    subject { CommandWorkers::DcmSubscribeWorker.new }
    it 'uses lowest status code' do
      subject.http_response = stub(status: 200)
      subject.http_response = stub(status: 404)
      subject.http_response.status.should eq(200)
    end
  end

  context "with subscribe args" do

    it 'should call email_subscribe on the DCM Client when argument has an asterisk' do
      options[:sms_tokens] = ['em@il']
      client.expects(:email_subscribe).with('em@il', command_parameters.dcm_account_code, command_parameters.dcm_topic_codes)
      subject.request_subscription(client, '', CommandParameters.new(options), command_parameters)
    end

    it 'should call wireless_subscribe on the DCM Client when argument does not have an asterisk' do
      options[:sms_tokens] = ['n`email']
      client.expects(:wireless_subscribe).with('5', command_parameters.dcm_account_code, command_parameters.dcm_topic_codes)
      subject.request_subscription(client, '5', CommandParameters.new(options), command_parameters)
    end
  end

end
