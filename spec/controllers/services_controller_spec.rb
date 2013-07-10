require 'spec_helper'
describe ServicesController do
  let(:vendor) { create_sms_vendor }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }

  it "should show services" do
    sign_in user
    get :index
    response.response_code.should == 200
  end

  it "should not allow any method other than GET" do
    sign_in user
    post :index
    response.response_code.should == 400
  end

end
