require 'spec_helper'
describe DcmUnsubscribeWorker do
  let(:config) { {:username => "foo", :password => "bar", :api_root => "http://example.com"} }
  let(:client) { mock('dcm_client') }

  describe 'perform with one account' do
    before do
      Tsms::Application.config.expects(:dcm).returns(config)
      client.expects(:delete_wireless_subscriber).with("1+2222222222", "ACME")
      DCMClient::Client.expects(:new).with(config).returns(client)
    end
    specify { DcmUnsubscribeWorker.new.perform({:dcm_account_codes => ["ACME"], :from => "+12222222222" }) }
  end

  describe 'perform with two accounts and one 404' do
    before do
      Tsms::Application.config.expects(:dcm).returns(config)
      client.expects(:delete_wireless_subscriber)
        .with("1+2222222222", "ACME")
        .raises(DCMClient::Error::NotFound.new("foo"))
      client.expects(:delete_wireless_subscriber)
        .with("1+2222222222", "VANDELAY")
        .raises(DCMClient::Error::NotFound.new("foo"))

      DCMClient::Client.expects(:new).with(config).returns(client)
    end
    specify { DcmUnsubscribeWorker.new.perform({:dcm_account_codes => ["ACME","VANDELAY"], :from => "+12222222222" }) }
  end 
end
