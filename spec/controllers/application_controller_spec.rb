require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do
  controller do
    def show
      raise ActiveRecord::RecordNotFound
    end

    def index
      render :text => "3oo" 
    end
  end

  describe "raising an ActiveRecord::RecordNotFound" do
    let(:vendor) { create_sms_vendor }
    let(:account) { vendor.accounts.create(:name => 'name') }
    let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
    before do
      sign_in user
    end

    it "should 404" do
      get :show, :id => 1
      response.response_code.should eq(404)
    end
  end


  describe "using the X-AUTH-TOKEN header" do
    let(:vendor) { create_sms_vendor }
    let(:account) { vendor.accounts.create(:name => 'name') }
    let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }

    before do 
      request.env['X-AUTH-TOKEN'] = user.authentication_token
    end

    it "should log a user in with that auth token" do
      get :index
      response.response_code.should eq(200)
      controller.current_user.should eq(user)
    end
  end
end