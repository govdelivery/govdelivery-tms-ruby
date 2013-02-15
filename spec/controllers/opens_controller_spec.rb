require 'spec_helper'

describe OpensController do

  let(:vendor) { create_sms_vendor }
  let(:account) { vendor.accounts.create!(name: 'name') }
  let(:user) { account.users.create!(email: 'foo@evotest.govdelivery.com', password: "schwoop") }
  let(:email_message) { user.email_messages.create!(subject: "subs", from_name: 'dude', body: 'hi') }
  let(:email_recipient) {
    email_message.create_recipients([email: "dude@sink.govdelivery.com"])
    email_message.recipients.first
  }
  let(:opens) {
    # opened seven times - once per minute
    7.times.map{|i| email_recipient.opened!('0.0.0.0', Time.at(1359784800 + (i * 60)))}
  }

  before do
    sign_in user
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index', email_id: email_message.id, recipient_id: email_recipient.id
      response.response_code.should == 200
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'show', email_id: email_message.id, recipient_id: email_recipient.id, id: opens.first.id
      response.response_code.should == 200
    end
  end

end
