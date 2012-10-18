require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController, "new with a valid message" do
  before { MessageWorker.stubs(:perform_async).returns(true) }
  
  def do_create
    post :create, message: { :short_body => 'A short body', 
      :recipients_attributes => [
        {:country_code => '1', :phone => '6515551000'},
        {:country_code => '44', :phone => '6515551001'}
      ]},
      :format => :json 
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Message" do
        expect {
          do_create
        }.to change(Message, :count).by(1)
      end

      it "creates two recipients" do
        expect {
          do_create
        }.to change(Recipient, :count).by(2)
      end
      
      it "assigns a newly created message as @message" do
        do_create
        assigns(:message).should be_a(Message)
        assigns(:message).should be_persisted
      end

      it "should be accepted" do
        do_create
        response.should be_success
      end
    end
  end
  
end