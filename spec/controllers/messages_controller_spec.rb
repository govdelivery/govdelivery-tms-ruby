require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController, "#create with a valid message" do
  before { Message.any_instance.expects(:save).returns(true) }

  def do_create
    post :create, message: { :short_body => 'A short body'}, :format => :json
  end
  
  it "should be accepted" do
    do_create
    response.response_code.should == 202
  end

  it "should populate new Message" do
    do_create
    assigns(:message).short_body.should == 'A short body'
  end
end

describe MessagesController, "#create with an invalid message" do
  before { Message.any_instance.expects(:save).returns(false) }

  def do_create
    post :create, message: { :short_body => 'A short body'}, :format => :json
  end
  
  it "should be unprocessable_entity" do
    do_create
    response.response_code.should == 422
  end

  it "should populate new Message" do
    do_create
    assigns(:message).short_body.should == 'A short body'
  end
end
# describe MessagesController, "#show with a message" do
#   before do
#     @message = mock('message', :as_json => "Hey Kool Aid!")
#     Message.expects(:find_by_id).with('12').returns(@message)
#   end
# 
#   def do_create
#     get :show, :id=>'12', :format => :json
#   end
#   
#   it "should be success" do
#     do_create
#     response.response_code.should == 200
#   end
# end
# 
# describe MessagesController, "#show with message not found" do
#   before do
#     Message.expects(:find_by_id).with('12').returns(nil)
#   end
# 
#   def do_create
#     get :show, :id=>'12', :format => :json
#   end
#   
#   it "should be success" do
#     do_create
#     response.response_code.should == 200
#   end
# end