require 'rails_helper'

describe RecipientsController do
  describe "routing" do

    context 'email' do
      it " routes to #failed" do
        expect(get("/messages/email/12345/recipients/failed" )).to route_to("recipients#failed", email_id: '12345')
      end

      it "routes to #sent" do
        expect(get("/messages/email/12345/recipients/sent" )).to route_to("recipients#sent", email_id: '12345')
      end

      it "does not route to #blacklisted" do
        # because that is for the sms path
        expect(get("/messages/email/12345/recipients/blacklisted" )).not_to route_to("recipients#blacklisted", email_id: '12345')
      end
    end

    context 'sms' do
      it " routes to #failed" do
        expect(get("/messages/sms/12345/recipients/failed" )).to route_to("recipients#failed", sms_id: '12345')
      end
      it " routes to #sent" do
        expect(get("/messages/sms/12345/recipients/sent" )).to route_to("recipients#sent", sms_id: '12345')
      end

      it " does not route to #opened" do
        # because that is on the email path
        expect(get("/messages/sms/12345/recipients/opened" )).not_to route_to("recipients#opened", sms_id: '12345')
      end
    end

    context 'phone' do
      it " routes to #failed" do
        expect(get("/messages/voice/12345/recipients/failed" )).to route_to("recipients#failed", voice_id: '12345')
      end
      it " routes to #sent" do
        expect(get("/messages/voice/12345/recipients/sent" )).to route_to("recipients#sent", voice_id: '12345')
      end

      it " does not route to #opened" do
        # because that is on the email path
        expect(get("/messages/voice/12345/recipients/opened" )).not_to route_to("recipients#opened", voice_id: '12345')
      end
    end
  end
end
