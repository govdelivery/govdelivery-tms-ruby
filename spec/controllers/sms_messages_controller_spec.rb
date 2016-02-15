require 'rails_helper'

def do_create_sms
  post :create, message: {body: 'A short body'}, format: :json
end

describe SmsMessagesController do
  let(:vendor) {create(:sms_vendor)}
  let(:account) {vendor.accounts.create(name: 'name')}
  let(:user) {account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop')}
  let(:model) {SmsMessage}
  let(:sms_template) {create(:sms_template, body: 'sms template body', user: user, account: account)}
  let(:recipients) {[{phone: "800BUNNIES"}]}
  let(:templated_messages) {create_list(:sms_message, 3, sms_template: sms_template, account: account)}
  let(:messages) do
    3.times.collect do |i|
      m = SmsMessage.new(body: "#{'A' * 40} #{i}",
                         recipients_attributes: [{phone: '800BUNNIES'}])
      m.created_at = i.days.ago
    end
  end

  before do
    sign_in user
  end

  it_should_have_a_pageable_index(:messages, User, :sms_messages)
  it_should_create_a_message(body: 'A short body')

  it_should_show_with_attributes(:body)

  context "using a template" do
    it_should_create_a_message(_links: :sms_template_link)
    it_should_have_a_pageable_index(:templated_messages, User, :sms_messages)
    it_should_show_with_attributes(:body)

    it "should apply the template to the message" do
      post :create, message: {recipients: recipients, body: nil, _links: {sms_template: sms_template.uuid}}
      expect(response.response_code).to eq(201)
      expect(assigns(:message).sms_template).to eq(sms_template)
      expect(assigns(:message).body).to eq(sms_template.body)
    end

    it "should apply a template by id if no uuid is set" do
      post :create, message: {recipients: recipients, body: nil, _links: {sms_template: sms_template.id.to_s}}
      expect(response.response_code).to eq(201)
      expect(assigns(:message).sms_template).to eq(sms_template)
      expect(assigns(:message).body).to eq(sms_template.body)
    end

    it "should apply a template by uuid if uuid is set" do
      new_template = create(:sms_template, body: 'sms template body', user: user, account: account, uuid: "sweet-template")
      post :create, message: {recipients: recipients, body: nil, _links: {sms_template: new_template.uuid}}
      expect(response.response_code).to eq(201)
      expect(assigns(:message).sms_template).to eq(new_template)
      expect(assigns(:message).body).to eq(new_template.body)
    end

    it "should not apply a template by id if uuid is set" do
      new_template = create(:sms_template, body: 'sms template body', user: user, account: account, uuid: "sweet-template")
      post :create, message: {recipients: recipients, body: nil, _links: {sms_template: new_template.id.to_s}}
      expect(response.response_code).to eq(422)
    end
  end
end
