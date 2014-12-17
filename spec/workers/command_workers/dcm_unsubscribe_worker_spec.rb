require 'rails_helper'
describe CommandWorkers::DcmUnsubscribeWorker do
  let(:config) { {:username => "foo", :password => "bar", :api_root => "http://example.com"} }
  let(:client) { mock('dcm_client') }
  let(:account) { create(:account) }
  let(:command) do
    create(:dcm_unsubscribe_command,
           keyword: account.stop_keyword,
           params:  build(:unsubscribe_command_parameters,
                          dcm_account_codes: Array(account.dcm_account_codes)))
  end

  let(:http_response) do
    stub('http_response',
         status:  200,
         headers: {'Content-Type' => 'andrew/json'},
         body:    'foo')
  end

  let(:response_not_found) do
    stub('http_response_404',
         status:  404,
         headers: {'Content-Type' => 'andrew/json'},
         body:    'nope')
  end

  let(:options) do
    {
      from:               "+12222222222",
      inbound_message_id: create(:inbound_message).id,
      command_id:         command.id
    }
  end

  before(:each) do
    Xact::Application.config.expects(:dcm).returns(config)
  end

  subject do
    CommandWorkers::DcmUnsubscribeWorker.new
  end

  describe 'perform with one account' do
    before do
      client.expects(:delete_wireless_subscriber).with("1+2222222222", "ACME").returns(http_response)
      DCMClient::Client.expects(:new).with(config).returns(client)
    end
    specify { subject.perform(options) }
  end

  describe 'perform with two accounts and one 404' do
    before do
      client.expects(:delete_wireless_subscriber)
        .with("1+2222222222", "VANDELAY")
        .raises(DCMClient::Error::NotFound.new("foo", response_not_found))
      client.expects(:delete_wireless_subscriber).with("1+2222222222", "ACME").returns(http_response)

      DCMClient::Client.expects(:new).with(config).returns(client)
      account = command.account
      account.dcm_account_codes = ["ACME", "VANDELAY"].to_set
      account.save!
      command.params.dcm_account_codes = ["ACME", "VANDELAY"]
      command.save!
    end
    specify do
      subject.perform(options)
      subject.http_response.status.should eq(200)
    end
  end
end
