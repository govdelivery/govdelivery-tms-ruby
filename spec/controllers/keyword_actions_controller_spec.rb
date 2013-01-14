require 'spec_helper'

describe KeywordActionsController do
  let(:vendor)  { Vendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') }
  let(:account) { vendor.accounts.create! :name=> "HELLO ACCOUNT" }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:keyword) { k=account.keywords.new(:name => "HI").tap{|k| k.vendor = vendor}; k.save!; k }
  let(:action) { Action.new(:action_type => :dcm_subscribe, :name => "ALLIGATORZ") }

  before do
    sign_in user
  end

  context "Listing a keyword's actions" do
    before do
      Keyword.any_instance.expects(:actions).returns([stub(:name => "FOO", :params => {:hi => "there"})])
      get :index, :keyword_id => keyword.id, :format => :json
    end
    it "should work" do
      response.response_code.should == 200
    end
  end
  context "Displaying an action" do
    before do
      find = mock
      find.expects(:find).with('22').returns(action)
      Keyword.any_instance.expects(:actions).returns(find)
      get :show, :keyword_id => keyword.id, :id => '22'
    end
    it "should work" do
      response.response_code.should == 200
    end
  end
  
  context "Creating an action" do
    before do
      Action.any_instance.expects(:save).returns(true)
      Action.any_instance.expects(:new_record).returns(false)
      post :create, :keyword_id => keyword.id, :action => {
        :name => "Hello Boston", 
        :action_type => "dcm_unsubscribe", 
        :params => {
          :dcm_account_codes => ["ACME"]
        }
      }
    end
    it "should work" do
      response.response_code.should == 201
    end
  end
  context "Creating an invalid action" do
    before do
      
    end
    it "should return error" do
      response.response_code.should == 422
    end
  end
end
