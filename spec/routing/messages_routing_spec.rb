require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController do
  describe "routing" do

    it "routes to sms#create" do
      post("/messages/sms" ).should route_to("sms_messages#create")
    end

    it "routes to voice#create" do
      post("/messages/voice" ).should route_to("voice_messages#create")
    end

    it "routes to recipients#clicked" do
      get("/messages/email/1/recipients/clicked").should route_to("recipients#clicked", :email_id => '1')
    end

    it "routes to recipients#opened" do
      get("/messages/email/1/recipients/opened").should route_to("recipients#opened", :email_id => '1')
    end    
  end
end
