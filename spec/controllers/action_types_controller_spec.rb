require File.dirname(__FILE__) + '/../spec_helper'

describe ActionTypesController do

  let(:vendor) { Vendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }

  context "a get to index" do
    before do
      sign_in user
      get :index, :format => :json
    end

    it "should render correctly" do
      response.response_code.should == 200
    end
  end
end
