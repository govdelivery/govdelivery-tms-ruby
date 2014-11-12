require 'rails_helper'

describe KeywordsController do
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:vendor) { create(:sms_vendor) }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:attrs) { {'name' => "GOVD", 'response_text' => "GovAwesome!"} }
  let(:keywords) { [stub(:name => "HI" )] }
  let(:keyword) { mock("keyword") }

  before do
    sign_in user
  end

  context "Listing keywords" do
    before do
      custom = mock()
      custom.expects(:custom).returns(keywords)
      Account.any_instance.expects(:keywords).returns(custom)
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
      keywords.expects(:new).with(attrs).returns(keyword)
      Account.any_instance.expects(:keywords).returns(keywords)
      keyword.expects(:save).returns(true)
      keyword.stubs(:new_record?).returns(false)
      post :create, :keyword => attrs, :format => :json
    end
    it "should create a keyword" do
      response.response_code.should == 201
    end
  end
  context "Creating an invalid keyword" do
    before do
      Keyword.any_instance.expects(:save).returns(false)
      Keyword.any_instance.stubs(:new_record?).returns(true)
      post :create, :keyword => attrs, :format => :json
    end
    it "should return error" do
      response.response_code.should == 422
    end
  end
  context "Updating a valid keyword" do
    before do
      keywords.first.expects(:update_attributes).with(attrs).returns(true)
      keywords.first.expects(:valid?).returns(true)
      mock_finder('twelve')
      put :update, :id => 'twelve', :keyword => attrs,
          :format => :json
    end
    it "should update" do
      response.response_code.should == 200
    end
  end
  context "Updating an invalid keyword" do
    before do
      keywords.first.expects(:update_attributes).with(attrs).returns(false)
      keywords.first.expects(:valid?).returns(false)
      mock_finder('twelve')
      put :update, :id => 'twelve', :keyword => attrs,
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
    custom_keywords = mock()
    find.expects(:find).with(id).returns(keywords.first)
    custom_keywords.expects(:custom).returns(find)
    Account.any_instance.expects(:keywords).returns(custom_keywords)
  end
end
