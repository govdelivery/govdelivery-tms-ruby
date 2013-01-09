require "spec_helper"

describe InboundMessagesController do
  describe "routing" do

    it "routes to #index" do
      get("/inbound/sms").should route_to("inbound_messages#index")
    end

    it "routes to #show" do
      get("/inbound/sms/1").should route_to("inbound_messages#show", :id => "1")
    end
  end
end
