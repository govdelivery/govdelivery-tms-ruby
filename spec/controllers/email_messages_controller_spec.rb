require 'spec_helper'

describe EmailMessagesController do
  let(:vendor) { create_email_vendor(:name => 'name', :username => 'username', :password => 'secret', :worker => 'OdmWorker') }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:messages) do
    3.times.collect do |i|
      m = EmailMessage.new(:body => "#{"A"*40} #{i}",
                           :subject => 'n/a',
                           :recipients_attributes => [{:email => "800BUNNIES"}])
      m.created_at = i.days.ago
    end
  end

  before do
    sign_in user
  end

  it_should_create_a_message(EmailMessage, {:body => 'A short body'})

  it_should_have_a_pageable_index(EmailMessage)
end
