require 'rails_helper'

describe KeywordsController do
  let(:account) { vendor.accounts.create(name: 'name') }
  let(:vendor) { create(:sms_vendor) }
  let(:user) { account.users.create(email: 'foo@evotest.govdelivery.com', password: "schwoop") }
  let(:attrs) { {'name' => "GOVD", 'response_text' => "GovAwesome!"} }
  let(:keywords) { [stub(name: "HI")] }
  let(:keyword) { mock("keyword") }

  before do
    sign_in user
  end

  context "Listing keywords" do
    before do
      keywords.stubs(:page).returns(keywords)
      keywords.stubs(:total_pages).returns(5)
      Account.any_instance.expects(:keywords).returns(keywords)
    end
    it "should work on the first page" do
      keywords.stubs(:current_page).returns(1)
      keywords.stubs(:first_page?).returns(true)
      keywords.stubs(:last_page?).returns(false)
      get :index
      response.response_code.should == 200
      response.headers['Link'].should_not =~ /first/
      response.headers['Link'].should_not =~ /prev/
      response.headers['Link'].should =~ /next/
      response.headers['Link'].should =~ /last/
    end

    it "should have all links" do
      keywords.stubs(:current_page).returns(2)
      keywords.stubs(:first_page?).returns(false)
      keywords.stubs(:last_page?).returns(false)
      get :index, page: 2
      response.response_code.should == 200
      response.headers['Link'].should =~ /first/
      response.headers['Link'].should =~ /prev/
      response.headers['Link'].should =~ /next/
      response.headers['Link'].should =~ /last/
    end

    it "should have prev and first links" do
      keywords.stubs(:current_page).returns(3)
      keywords.stubs(:first_page?).returns(false)
      keywords.stubs(:last_page?).returns(true)
      get :index, page: 3
      response.response_code.should == 200
      response.headers['Link'].should =~ /first/
      response.headers['Link'].should =~ /prev/
      response.headers['Link'].should_not =~ /next/
      response.headers['Link'].should_not =~ /last/
    end
  end
  context "Showing a keyword" do
    before do
      mock_finder('twelve')
      get :show, id: 'twelve'
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
      post :create, keyword: attrs
    end
    it "should create a keyword" do
      response.response_code.should == 201
    end
  end
  context "Creating an invalid keyword" do
    before do
      Keyword.any_instance.expects(:save).returns(false)
      Keyword.any_instance.stubs(:new_record?).returns(true)
      post :create, keyword: attrs
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
      put :update, id: 'twelve', keyword: attrs
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
      put :update, id: 'twelve', keyword: attrs
    end
    it "should return error" do
      response.response_code.should == 422
    end
  end
  context "Deleting a keyword" do
    before do
      keywords.first.expects(:destroy)
      find = mock()
      custom = mock()
      custom.expects(:custom).returns(find)
      find.expects(:find).with('twelve').returns(keywords.first)
      Account.any_instance.expects(:keywords).returns(custom)
      delete :destroy, id: 'twelve'
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
