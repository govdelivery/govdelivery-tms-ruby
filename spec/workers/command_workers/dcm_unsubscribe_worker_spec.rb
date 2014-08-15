require 'rails_helper'
describe CommandWorkers::DcmUnsubscribeWorker do
  let(:config) { [{:username => "foo", :password => "bar", :api_root => "http://example.com"},
                  {:username => "foo", :password => "bar", :api_root => "http://example2.com"}] }
  let(:client) { mock('dcm_client') }
  let(:command) { mock('Command', process_response: nil) }
  let(:account) { stub('account', id: 100, to_param: 100) }

  let(:http_response) { stub(status: 200) }
  let(:response_not_found){ stub(status: 404) }

  subject do
    w = CommandWorkers::DcmUnsubscribeWorker.new
    w.stubs(:command).returns(command)
    w.stubs(:account).returns(account)
    w
  end

  describe 'perform with one account' do
    before do
      Xact::Application.config.expects(:dcm).returns(config)
      client.expects(:delete_wireless_subscriber).with("1+2222222222", "ACME").returns(http_response)
      client.expects(:delete_wireless_subscriber).with("1+2222222222", "ACME").returns(http_response)
      DCMClient::Client.expects(:new).with(config[0]).returns(client)
      DCMClient::Client.expects(:new).with(config[1]).returns(client)
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

      client.expects(:delete_wireless_subscriber).with("1+2222222222", "ACME").returns(http_response)
      client.expects(:delete_wireless_subscriber)
        .with("1+2222222222", "VANDELAY")
        .raises(DCMClient::Error::NotFound.new("foo", response_not_found))

      DCMClient::Client.expects(:new).with(config[0]).returns(client)
      DCMClient::Client.expects(:new).with(config[1]).returns(client)
    end
    specify do 
      subject.perform({:dcm_account_codes => ["ACME","VANDELAY"], :from => "+12222222222" })
      subject.http_response.status.should eq(200)
    end
  end
end
