require "rails_helper"

describe EmailTemplatesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/email_templates").to route_to("email_templates#index")
    end

    it "routes to #show" do
      expect(:get => "/email_templates/1").to route_to("email_templates#show", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/email_templates").to route_to("email_templates#create")
    end

    it "routes to #update" do
      expect(:put => "/email_templates/1").to route_to("email_templates#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/email_templates/1").to route_to("email_templates#destroy", :id => "1")
    end

  end
end
