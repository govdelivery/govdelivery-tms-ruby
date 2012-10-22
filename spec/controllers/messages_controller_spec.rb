require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController, "#create with a valid message" do
  before do
    @username = 'username'
    @password = 'password'

    @vendor = Vendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker')
    @account = @vendor.accounts.create(:name => 'name')
    @user = @account.users.create(:username => 'username')
    Message.any_instance.expects(:save).returns(true)
    LoopbackMessageWorker.expects(:perform_async).with(anything).returns(true)
  end

  def encoded_credentials
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(@username, @password)    
  end
  
  def do_create
    post :create, :message => { :short_body => 'A short body'}, :format => :json, :authorization => encoded_credentials
  end
  
  it "should be accepted" do
    do_create
    response.response_code.should == 200
  end

  it "should populate new Message" do
    do_create
    assigns(:message).short_body.should == 'A short body'
  end
end

describe MessagesController, "#create with an invalid message" do
  before do
    @username = 'username'
    @password = 'password'

    @vendor = Vendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker')
    @account = @vendor.accounts.create(:name => 'name')
    @user = @account.users.create(:username => 'username')
    Message.any_instance.expects(:save).returns(false)
  end

  def encoded_credentials
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(@username, @password)    
  end
  
  def do_create
    post :create, :message => { :short_body => 'A short body'}, :format => :json, :authorization => encoded_credentials
  end
  
  it "should be unprocessable_entity" do
    do_create
    response.response_code.should == 200
  end

  it "should populate new Message" do
    do_create
    assigns(:message).short_body.should == 'A short body'
  end
end