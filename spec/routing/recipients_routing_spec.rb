require 'rails_helper'

describe RecipientsController do
  describe "routing" do

    context 'email' do
      it " routes to #failed" do
        get("/messages/email/12345/recipients/failed" ).should route_to("recipients#failed", email_id: '12345')
      end

      it "routes to #sent" do
        get("/messages/email/12345/recipients/sent" ).should route_to("recipients#sent", email_id: '12345')
      end

      it "does not route to #blacklisted" do
        # because that is for the sms path
        get("/messages/email/12345/recipients/blacklisted" ).should_not route_to("recipients#blacklisted", email_id: '12345')
      end
    end

    context 'sms' do
      it " routes to #failed" do
        get("/messages/sms/12345/recipients/failed" ).should route_to("recipients#failed", sms_id: '12345')
      end
      it " routes to #sent" do
        get("/messages/sms/12345/recipients/sent" ).should route_to("recipients#sent", sms_id: '12345')
      end

      it " does not route to #opened" do
        # because that is on the email path
        get("/messages/sms/12345/recipients/opened" ).should_not route_to("recipients#opened", sms_id: '12345')
      end
    end

    context 'phone' do
      it " routes to #failed" do
        get("/messages/voice/12345/recipients/failed" ).should route_to("recipients#failed", voice_id: '12345')
      end
      it " routes to #sent" do
        get("/messages/voice/12345/recipients/sent" ).should route_to("recipients#sent", voice_id: '12345')
      end

      it " does not route to #opened" do
        # because that is on the email path
        get("/messages/voice/12345/recipients/opened" ).should_not route_to("recipients#opened", voice_id: '12345')
      end
    end
  end
end
