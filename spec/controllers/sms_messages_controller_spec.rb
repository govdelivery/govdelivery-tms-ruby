require File.dirname(__FILE__) + '/../spec_helper'

def do_create_sms
  post :create, :message => {:body => 'A short body'}, :format => :json
end

describe SmsMessagesController do
  let(:vendor) { create_sms_vendor }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:messages) do
        3.times.collect do |i|
          m = SmsMessage.new(:body => "#{"A"*40} #{i}",
                          :recipients_attributes => [{:phone => "800BUNNIES"}])
          m.created_at = i.days.ago
        end
  end

  before do
    sign_in user
  end

  it_should_create_a_message(SmsMessage, {:body => 'A short body'})

  it_should_have_a_pageable_index(SmsMessage)

end
