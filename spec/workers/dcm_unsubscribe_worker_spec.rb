require 'spec_helper'
describe DcmUnsubscribeWorker do
  let(:config) { {:username => "foo", :password => "bar", :api_root => "http://example.com"} }
  let(:client) { mock('dcm_client') }
  let(:response_not_found){ {code: 404} }
  let(:command) { mock('Command', process_response: nil) }
  let(:account) { stub('account', id: 100, to_param: 100) }
  let(:http_response) { stub(status: 200) }

  subject do
    w = DcmUnsubscribeWorker.new
    w.stubs(:command).returns(command)
    w.stubs(:account).returns(account)
    w
  end

  describe 'perform with one account' do
    before do
      Xact::Application.config.expects(:dcm).returns(config)
      client.expects(:delete_wireless_subscriber).with("1+2222222222", "ACME").returns(http_response)
      DCMClient::Client.expects(:new).with(config).returns(client)
    end
    specify { subject.perform({:dcm_account_codes => ["ACME"], :from => "+12222222222" }) }
  end

  describe 'perform with two accounts and one 404' do
    before do
      Xact::Application.config.expects(:dcm).returns(config)
      client.expects(:delete_wireless_subscriber)
        .with("1+2222222222", "ACME")
        .raises(DCMClient::Error::NotFound.new('what', response_not_found))
      client.expects(:delete_wireless_subscriber)
        .with("1+2222222222", "VANDELAY")
        .raises(DCMClient::Error::NotFound.new("foo", response_not_found))

      DCMClient::Client.expects(:new).with(config).returns(client)
    end
    specify { subject.perform({:dcm_account_codes => ["ACME","VANDELAY"], :from => "+12222222222" }) }
  end 
end
