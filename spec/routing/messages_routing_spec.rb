require 'rails_helper'

describe MessagesController do
  describe "routing" do

    it "routes to sms#create" do
      expect(post("/messages/sms" )).to route_to("sms_messages#create")
    end

    it "routes to voice#create" do
      expect(post("/messages/voice" )).to route_to("voice_messages#create")
    end
  end
end
