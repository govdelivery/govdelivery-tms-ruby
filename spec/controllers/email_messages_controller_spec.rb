require 'rails_helper'

describe EmailMessagesController do
  let(:vendor) {create(:email_vendor, worker: Odm::TMS_EXTENDED_WORKER)}
  let(:account) {create(:account, name: 'name', email_vendor: vendor)}
  let(:user) {account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop')}
  let(:messages) do
    3.times.collect do |i|
      m = EmailMessage.new(
        body:                   "#{'A' * 40} #{i} [[happy]]",
        subject:                'n/a',
        from_email:             'duane@everythingsucks.com',
        errors_to:              'jeff@everythingsucks.com',
        reply_to:               'bob@everythingsucks.com',
        click_tracking_enabled: true,
        open_tracking_enabled:  false,
        macros:                 {'happy' => 'doggies'},
        recipients_attributes:  [{email: '800BUNNIES'}]
      )
      m.created_at = i.days.ago
      m
    end
  end

  let(:model) {EmailMessage}

  before do
    sign_in user
  end

  it_should_create_a_message(body:                   "#{'A' * 40} [[happy]]",
                             subject:                'n/a',
                             from_email:             'duane@everythingsucks.com',
                             errors_to:              'jeff@everythingsucks.com',
                             reply_to:               'bob@everythingsucks.com',
                             click_tracking_enabled: true,
                             open_tracking_enabled:  false,
                             macros:                 {'happy' => 'doggies'},
                             recipients_attributes:  [{email: '800BUNNIES'}])

  it_should_have_a_pageable_index(:messages, User, :email_messages_indexed)

  it_should_show_with_attributes(:body,
                                 :subject,
                                 :from_name,
                                 :from_email,
                                 :errors_to,
                                 :reply_to,
                                 :click_tracking_enabled,
                                 :open_tracking_enabled,
                                 :macros)
end
