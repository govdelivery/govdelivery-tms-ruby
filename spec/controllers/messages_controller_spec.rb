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
end
