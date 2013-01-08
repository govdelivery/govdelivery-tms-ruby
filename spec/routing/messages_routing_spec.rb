require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController do
  describe "routing" do

    it "routes to sms#create" do
      post("/sms_messages" ).should route_to("sms_messages#create")
    end

    it "routes to voice#create" do
      post("/voice_messages" ).should route_to("voice_messages#create")
    end
  end
end
