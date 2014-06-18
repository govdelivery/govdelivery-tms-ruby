require 'spec_helper'
describe DcmSubscribeWorker do
  let(:phone_number) { '+14443332222' }
  let(:account_code) { 'ACCOUNT_CODE' }
  let(:topic_codes) { ['TOPIC_CODE', 'TOPIC_2'] }
  let(:subscribe_args) { ['foo@bar.com'] }

  let(:command) { stub('Command', process_response: nil) }
  let(:account) { stub('account', id: 100, to_param: 100) }

  let(:http_response) { stub(status: 200) }
  let(:http_failure_response) { stub(status: 422) }
  let(:http_404_response) { stub(status: 404) }
  let(:client) { mock('dcm_client') }

  subject do
    w = DcmSubscribeWorker.new
    w.stubs(:command).returns(command)
    w.stubs(:account).returns(account)
    w
  end

  context 'error handling' do

    it 'passes options to the subscribe command' do
      opts = build(:subscribe_command_parameters, from: '5' ).to_hash
      subject.expects(:request_subscription).with(kind_of(DCMClient::Client), '1+5', kind_of(CommandParameters))
      subject.perform(opts)
    end

    it 'ignores 422s' do
      opts = build(:subscribe_command_parameters ).to_hash
      subject.expects(:request_subscription).raises( DCMClient::Error::UnprocessableEntity.new("foo", http_failure_response) )
      expect{ subject.perform(opts) }.to_not raise_error
    end

    it 'ignores 404s' do
      opts = build(:subscribe_command_parameters ).to_hash
      subject.expects(:request_subscription).raises( DCMClient::Error::NotFound.new("foo", http_404_response) )
      expect{ subject.perform(opts) }.to_not raise_error
    end

    it 'raises other exceptions' do
      opts = build(:subscribe_command_parameters ).to_hash
      subject.expects(:request_subscription).raises( Exception.new('hi') )
      expect{ subject.perform(opts) }.to raise_error(Exception)
    end
  end

  context 'multiple requests' do
    subject{ DcmSubscribeWorker.new }
    it 'uses lowest status code' do
      subject.http_response = stub(status: 200)
      subject.http_response = stub(status: 404)
      subject.http_response.status.should eq(200)
    end
  end

  context "with subscribe args" do

    it 'should call email_subscribe on the DCM Client when argument has an asterisk' do
      command_parameters = build(:subscribe_command_parameters, sms_tokens: ['em@il'] ) #sets email subscribe
      client.expects(:email_subscribe).with('em@il', command_parameters.dcm_account_code, command_parameters.dcm_topic_codes)
      subject.request_subscription client, '', command_parameters
    end

    it 'should call wireless_subscribe on the DCM Client when argument does not have an asterisk' do
      command_parameters = build(:subscribe_command_parameters, sms_tokens: ['n`email'] ) #sets email subscribe
      client.expects(:wireless_subscribe).with('5', command_parameters.dcm_account_code, command_parameters.dcm_topic_codes)
      subject.request_subscription client, '5', command_parameters
    end
  end

end
