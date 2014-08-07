require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do
  # See rspec-rails for docs on how to use this.  
  # I think it only supports default route methods. 
  controller do
    # used to test exception handling
    def show
      raise eval(params[:id])    # ActiveRecord::RecordNotFound
                                 # MultiJson::LoadError
    end

    def index
      render :text => "3oo" 
    end
  end

  describe "when handling exceptions" do
    let(:vendor) { create(:sms_vendor) }
    let(:account) { vendor.accounts.create(:name => 'name') }
    let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }

    before do
      sign_in user
    end

    it "should 404 when ActiveRecord::RecordNotFound " do
      get :show, :id => 'ActiveRecord::RecordNotFound'
      response.response_code.should eq(404)
    end

    it "should 400 when MultiJson::LoadError" do
      get :show, :id => 'MultiJson::LoadError'
      response.response_code.should eq(400)
      JSON.parse(response.body) # this shouldn't raise
    end
  end

  describe "using the X-AUTH-TOKEN header" do
    let(:vendor) { create(:sms_vendor) }
    let(:account) { vendor.accounts.create(:name => 'name') }
    let(:user) { account.users.create!(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
    let(:auth_token) { user.authentication_tokens.first.token }

    before do 
      request.headers['X-AUTH-TOKEN'] = auth_token
    end

    it "should log a user in with that auth token" do
      get :index
      response.response_code.should eq(200)
      controller.current_user.should eq(user)
    end

    describe "incorrectly" do
      before do 
        request.headers['X-AUTH-TOKEN'] = auth_token.succ
      end

      it "should return the correct response code when token is wrong" do
        get :index
        response.response_code.should eq(401)
      end
    end
  end
end
