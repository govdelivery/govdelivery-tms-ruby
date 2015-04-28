require 'rails_helper'

describe EmailMessagesController do
  let(:vendor) {create(:email_vendor, worker: Odm::TMS_EXTENDED_WORKER)}
  let(:account) {create(:account, name: 'name', email_vendor: vendor)}
  let(:user) {account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop')}
  let(:from_address) {account.default_from_address}
  let(:email_template) { create(:email_template, account: account, user: user, from_address: from_address) }
  let(:email_template_link) {{email_template: email_template.id}}
  let(:message) {create(:email_message, user: user)}
  let(:templated_message) {create(:email_message, user: user, email_template: email_template)}
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
  let(:templated_messages) {create_list(:email_message, 3, email_template: email_template)} 
  let(:recipients) {[{email: "arbys@everythingsucks.com"}]}

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
  context "using a template" do

    it_should_create_a_message(_links: :email_template_link)
    it_should_have_a_pageable_index(:templated_messages, User, :email_messages_indexed)
    it_should_show_with_attributes(:body,
                                   :subject,
                                   :from_name,
                                   :from_email,
                                   :errors_to,
                                   :reply_to,
                                   :click_tracking_enabled,
                                   :open_tracking_enabled,
                                   :macros)

    it "should use values in the template by default" do
      post :create, message: {recipients: recipients}, _links: {email_template: email_template.id}
      expect(response.response_code).to eq(201)
      new_message = assigns(:message)
      expect(new_message.body).to eq(email_template.body)
      expect(new_message.subject).to eq(email_template.subject)
      expect(new_message.macros).to eq(email_template.macros)
      expect(new_message.click_tracking_enabled).to eq(email_template.click_tracking_enabled)
      expect(new_message.open_tracking_enabled).to eq(email_template.open_tracking_enabled)
      expect(new_message.email_template).not_to be_blank
    end

    it "should use a template link_tracking_parameter if the template specifies it"
    it "should override template values with POSTed values"
    it "should properly resolve template macros"
    it "should properly resolve macros that are POSTed"
  end
end
