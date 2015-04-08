require "rails_helper"

describe InboundMessagesController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/inbound/sms")).to route_to("inbound_messages#index")
    end

    it "routes to #show" do
      expect(get("/inbound/sms/1")).to route_to("inbound_messages#show", :id => "1")
    end
  end
end
