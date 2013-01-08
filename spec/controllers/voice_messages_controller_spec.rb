require File.dirname(__FILE__) + '/../spec_helper'

def do_create_voice
  post :create, :message => {:url => 'http://com.com/'}, :format => :json
end

describe VoiceMessagesController do
  let(:vendor) { Vendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker', :voice => true) }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  before do
    sign_in user
  end

  context "#create with a valid voice message" do
    before do
      Message.any_instance.expects(:save).returns(true)
      Message.any_instance.stubs(:new_record?).returns(false)

      CreateRecipientsWorker.expects(:perform_async).with(anything).returns(true)
      do_create_voice
    end
    it "should be accepted" do
      response.response_code.should == 201
    end

    it "should populate new Message" do
      assigns(:message).url.should == 'http://com.com/'
    end
  end

  context "#create with an invalid voice message" do
    before do
      Message.any_instance.expects(:save).returns(false)
      Message.any_instance.stubs(:new_record?).returns(true)
      do_create_voice
    end

    it "should be unprocessable_entity" do
      response.response_code.should == 422
    end

    it "should populate new Message" do
      assigns(:message).url.should == 'http://com.com/'
    end
  end

  context "index" do
    let(:messages) do
      messages = 3.times.collect do |i|
        m = Message.new(:url => "http://com.com/#{i}",
                        :recipients_attributes => [{:phone => "800BUNNIES"}])
        m.created_at = i.days.ago
      end
    end
    before do
      messages.stubs(:total_pages).returns(5)
      User.any_instance.expects(:voice_messages).returns(stub(:page => messages))
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
