require 'rails_helper'

describe MessagesController do
  describe "routing" do

    it "routes to sms#create" do
      post("/messages/sms" ).should route_to("sms_messages#create")
    end

    it "routes to voice#create" do
      post("/messages/voice" ).should route_to("voice_messages#create")
    end
  end
end
