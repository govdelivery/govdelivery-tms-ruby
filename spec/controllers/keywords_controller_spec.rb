require 'spec_helper'

describe KeywordsController do
  let(:vendor) { create_sms_vendor }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:keywords) { [stub(:name => "HI" )]}
  
  before do
    sign_in user
  end
  
  context "Listing keywords" do
    before do
      Account.any_instance.expects(:keywords).returns(keywords)
    end
    it "should show keywords" do
      get :index
      response.response_code.should == 200
    end
  end
  context "Showing a keyword" do
    before do
      mock_finder('twelve')
      get :show, :id => 'twelve', :format => :json
    end
    it "should work" do
      response.response_code.should == 200
    end
  end
  context "Creating a valid keyword" do
    before do
      Keyword.any_instance.expects(:save).returns(true)
      Keyword.any_instance.stubs(:new_record?).returns(false)
      post :create, :keyword => {:name => "GOVD"}, :format => :json
    end
    it "should create a keyword" do
      response.response_code.should == 201
    end
  end
  context "Creating an invalid keyword" do
    before do
      Keyword.any_instance.expects(:save).returns(false)
      Keyword.any_instance.stubs(:new_record?).returns(true)
      post :create, :keyword => {:name => "GOVD"}, :format => :json
    end
    it "should return error" do
      response.response_code.should == 422
    end
  end
  context "Updating a valid keyword" do
    before do
      keywords.first.expects(:update_attributes).returns(true)
      keywords.first.expects(:valid?).returns(true)
      mock_finder('twelve')
      put :update, :id => 'twelve', :keyword => {:name => "OMG"},
          :format => :json    
    end
    it "should update" do
      response.response_code.should == 200
    end
  end
  context "Updating an invalid keyword" do
    before do
      keywords.first.expects(:update_attributes).returns(false)
      keywords.first.expects(:valid?).returns(false)
      mock_finder('twelve')
      put :update, :id => 'twelve', :keyword => {:name => "OMG"},
          :format => :json    
    end
    it "should return error" do
      response.response_code.should == 422
    end
  end
  context "Deleting a keyword" do
    before do
      keywords.first.expects(:destroy)
      mock_finder('twelve')
      delete :destroy, :id => 'twelve'
    end
    it "should work" do
      response.response_code.should == 200
    end
  end

  def mock_finder(id)
    find = mock()
    find.expects(:find).with(id).returns(keywords.first)
    Account.any_instance.expects(:keywords).returns(find)
  end 
end