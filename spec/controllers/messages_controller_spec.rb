require File.dirname(__FILE__) + '/../spec_helper'

def do_create
  post :create, :message => {:short_body => 'A short body'}, :format => :json
end

describe MessagesController do
  let(:vendor) { Vendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  before do
    sign_in user
  end

  context "#create with a valid message" do
    before do
      Message.any_instance.expects(:save).returns(true)
      Message.any_instance.stubs(:new_record?).returns(false)

      LoopbackMessageWorker.expects(:perform_async).with(anything).returns(true)
      do_create
    end
    it "should be accepted" do
      response.response_code.should == 201
    end

    it "should populate new Message" do
      assigns(:message).short_body.should == 'A short body'
    end
  end

  context "#create with an invalid message" do
    before do
      Message.any_instance.expects(:save).returns(false)
      Message.any_instance.stubs(:new_record?).returns(true)
      do_create
    end
    
    it "should be unprocessable_entity" do
      response.response_code.should == 422
    end

    it "should populate new Message" do
      assigns(:message).short_body.should == 'A short body'
    end
  end

  context "index" do
    let(:messages) do
      msgs = 3.times.collect do |i|
        m = Message.new(:short_body => "#{"A"*40} #{i}",
                        :recipients_attributes => [{:phone => "800BUNNIES"}])
        m.created_at = i.days.ago
      end
    end
    before do
      messages.stubs(:total_pages).returns(5)
      Account.any_instance.expects(:messages).returns(stub(:page => messages))
    end
    it "should work on the first page" do
      messages.stubs(:current_page).returns(1)
      messages.stubs(:first_page?).returns(true)
      messages.stubs(:last_page?).returns(false)
      get :index, :format=>:json
      response.response_code.should == 200
    end

    it "should have all links" do
      messages.stubs(:current_page).returns(2)
      messages.stubs(:first_page?).returns(false)
      messages.stubs(:last_page?).returns(false)
      get :index, :page => 2
      response.headers['Link'].should =~ /first/
      response.headers['Link'].should =~ /prev/
      response.headers['Link'].should =~ /next/
      response.headers['Link'].should =~ /last/
    end

    it "should have prev and first links" do
      messages.stubs(:current_page).returns(5)
      messages.stubs(:first_page?).returns(false)
      messages.stubs(:last_page?).returns(true)
      get :index, :page => 5
      response.headers['Link'].should =~ /first/
      response.headers['Link'].should =~ /prev/
      response.headers['Link'].should_not =~ /next/
      response.headers['Link'].should_not =~ /last/
    end
  end
end
