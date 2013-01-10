require 'spec_helper'

describe KeywordsController do
  let(:vendor) { Vendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:keywords) { stub(:name => "HI" )}
  
  context "Listing keywords" do
    before do
      Account.any_instance.expects(:keywords).returns(keywords)
    end
    it "should show keywords" do
      sign_in user
      get :index
      response.response_code.should == 200
    end
  end
end
