require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController do
  describe "routing" do

    it "routes to #create" do
      post("/messages").should route_to("messages#create")
    end
  end
end
