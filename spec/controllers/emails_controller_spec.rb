require 'spec_helper'

describe EmailsController do
  let(:vendor) { EmailVendor.create(:name => 'name', :username => 'username', :password => 'secret', :worker => 'TmsWorker') }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  before do
    sign_in user
  end

  describe "#create with a valid message" do
    before do
      email_params = {'body' => 'msg body',
                      'subject' => 'msg subject',
                      'recipients' => ['email@sink.govdelivery.com', 'email2@sink.govdelivery.com']}
      TmsWorker.expects(:perform_async).with(:email => email_params,
                                             :account_id => account.id).returns(true)
      post :create, {:email => email_params, :format => :json}
    end
    it "should be accepted" do
      response.response_code.should == 201
    end
  end

end
