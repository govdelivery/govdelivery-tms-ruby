require 'spec_helper'

describe EmailMessagesController do
  let(:vendor) { create(:email_vendor, worker: Odm::TMS_EXTENDED_WORKER) }
  let(:account) { vendor.accounts.create(name: 'name', from_address: create(:from_address)) }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:messages) do
    3.times.collect do |i|
      m = EmailMessage.new(:body => "#{"A"*40} #{i} [[happy]]",
                           :subject => 'n/a',
                           :click_tracking_enabled => true, 
                           :open_tracking_enabled => false,
                           :macros => {"happy" => "doggies"},
                           :recipients_attributes => [{:email => "800BUNNIES"}])
      m.created_at = i.days.ago
    end
  end
  let(:model){EmailMessage}

  before do
    sign_in user
  end

  it "should accept a body and a subject " do
    post :create, :message => {body: 'this', subject: 'that', recipients: [{email: 'someone@somewhere.com'}]}, :format => :json
    assigns(:message).errors.size.should == 0
    response.response_code.should == 201
  end

  it_should_have_a_pageable_index(:messages)

  it_should_show_with_attributes(:body, :subject, :from_name, :click_tracking_enabled, :open_tracking_enabled, :macros)
end
