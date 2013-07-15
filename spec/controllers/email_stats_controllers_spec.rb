require 'spec_helper'

[[ClicksController, :click], [OpensController, :open]].each do |klass, stat|
  describe klass do

    let(:email_message) {
      account = create(:sms_vendor).accounts.create!(name: 'name')
      user = account.users.create!(email: 'foo@evotest.govdelivery.com', password: "schwoop")
      user.email_messages.create!(subject: "subs", from_name: 'dude', body: 'hi')
    }
    let(:email_recipient) {
      email_message.create_recipients([email: "dude@sink.govdelivery.com"])
      email_message.recipients.first
    }
    let(:stats) {
      # seven times - once per minute
      7.times.map{ |i|
        email_recipient.send(:"#{stat}ed!",
                             'some-ip-or-web-address',
                             Time.at(1359784800 + (i * 60)))
      }
    }

    before do
      sign_in email_message.user
    end

    describe "GET #index" do
      before do
        # need to invoke since let bindings are lazy and stats isn't used before #get
        stats 
      end
      it "returns http success" do
        get 'index', email_id: email_message.id, recipient_id: email_recipient.id
        response.response_code.should == 200
        assigns(:page).should == 1
        assigns(:events).map(&:id).sort.should == stats.map(&:id).sort
        assigns(:events).should match_array stats
      end
    end

    describe "GET #show" do
      it "returns http success" do
        get 'show', email_id: email_message.id, recipient_id: email_recipient.id, id: stats.first.id
        response.response_code.should == 200
        assigns(:event).should_not be_nil
      end
    end

  end
end
