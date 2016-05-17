require 'rails_helper'

describe EmailMessagesController do
  let(:vendor) {create(:email_vendor, worker: Odm::TMS_EXTENDED_WORKER)}
  let(:account) {create(:account, name: 'name', email_vendor: vendor)}
  let(:user) {account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop')}
  let(:from_address) {account.default_from_address}
  let(:email_template) {create(:email_template, account: account, user: user, from_address: from_address)}
  let(:email_template_link) {{email_template: email_template.uuid}}
  let(:message) {create(:email_message, user: user)}
  let(:templated_message) {create(:email_message, user: user, email_template: email_template)}
  let(:messages) do
    3.times.collect do |i|
      m            = EmailMessage.new(
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
  let(:templated_messages) {create_list(:email_message, 3, email_template: email_template, user: user)}
  let(:recipients) {[{email: "arbys@everythingsucks.com"}]}
  let(:valid_params) do
    {
        body:                   "#{'A' * 40} [[happy]]",
        subject:                'n/a',
        from_email:             'duane@everythingsucks.com',
        errors_to:              'jeff@everythingsucks.com',
        reply_to:               'bob@everythingsucks.com',
        click_tracking_enabled: true,
        open_tracking_enabled:  false,
        macros:                 {'happy' => 'doggies'},
        recipients_attributes:  [{email: '800BUNNIES'}]
    }
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

    it "should apply the template to the message" do
      post :create, message: {recipients: recipients, body: nil, _links: {email_template: email_template.uuid}}
      expect(response.response_code).to eq(201)
      expect(assigns(:message).email_template).to eq(email_template)
      expect(assigns(:message).body).to eq(email_template.body)
    end

    it "should apply the template to the message by id if uuid was not explicit" do
      new_template = create(:email_template, account: account, user: user, from_address: from_address)
      post :create, message: {recipients: recipients, body: nil, _links: {email_template: new_template.id.to_s}}
      expect(response.response_code).to eq(201)
      expect(assigns(:message).email_template).to eq(new_template)
      expect(assigns(:message).body).to eq(new_template.body)
    end

    it "should apply the template to the message by uuid if uuid was explicit" do
      new_template = create(:email_template, account: account, user: user, from_address: from_address, uuid: "new_sweet_template")
      post :create, message: {recipients: recipients, body: nil, _links: {email_template: new_template.uuid}}
      expect(response.response_code).to eq(201)
      expect(assigns(:message).email_template).to eq(new_template)
      expect(assigns(:message).body).to eq(new_template.body)
    end

    it "should not apply the template to the message by id if uuid was set" do
      new_template = create(:email_template, account: account, user: user, from_address: from_address, uuid: "new-template")
      post :create, message: {recipients: recipients, body: nil, _links: {email_template: new_template.id.to_s}}
      expect(response.response_code).to eq(422)
    end

    it "should not require an existing from_address if the user is an admin" do
      user.admin = true
      user.save!
      post :create, message: {from_email: 'no@exist.me', recipients: recipients, body: nil, _links: {email_template: email_template.uuid}}
      expect(response.response_code).to eq(201)
    end
  end

  context 'with a message type' do
    it 'accepts message type as a string' do
      post :create, message: {recipients: recipients, body: nil, _links: {email_template: email_template.uuid}, message_type_code: 'salutations'}
      expect(response.response_code).to eq(201)
      expect(assigns(:message).message_type.code).to eq('salutations')
      expect(assigns(:message).message_type.label).to eq('Salutations')
    end
  end
end
