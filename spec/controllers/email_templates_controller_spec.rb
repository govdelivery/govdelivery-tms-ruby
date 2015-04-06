require 'rails_helper'

describe EmailTemplatesController do

  let(:account) { create(:account) }
  let(:other_account) { create(:account) }
  let(:admin_user) { create :user, account: account, admin: true }
  let(:from_address) { account.default_from_address }
  let(:new_from_address) { create(:from_address, account: account) }
  let(:other_from_address) { create(:from_address, account: other_account) }
  let(:email_templates) { create_list(:email_template, 3, account: account, user: admin_user, from_address: from_address) }
  let(:valid_params) do
    {
      email_template: {
        body: "<html><body>[HELLO]</body></html>",
        subject: "This is a test",
        link_tracking_parameters: "tracking=param&one=two",
        macros: {"HELLO" => "WORLD"},
        click_tracking_enabled: true,
        open_tracking_enabled: true
      }
    }
  end
  let(:model) { EmailTemplate }

  before do
    sign_in admin_user
  end

  it_should_have_a_pageable_index(:email_templates, Account)

  it "should create an email template" do
    expect(account.email_templates.count).to eq(0)
    post :create, valid_params
    expect(response.response_code).to eq(201)
    expect(account.email_templates.count).to eq(1)
  end

  it "should not create invalid email templates" do
    expect(account.email_templates.count).to eq(0)
    valid_params[:email_template].delete(:subject)
    post :create, valid_params
    expect(response.response_code).to eq(422)
    expect(account.email_templates.count).to eq(0)
  end

  it "should update an email template" do
    template = email_templates.first
    expect(template.open_tracking_enabled).to eq(false)
    patch :update, valid_params.merge(id: template.id)
    expect(response.response_code).to eq(200)
    template.reload
    expect(template.open_tracking_enabled).to eq(true)
  end

  it "should not update an email template to an invalid state" do
    template = email_templates.first
    expect(template.open_tracking_enabled).to eq(false)
    valid_params[:email_template][:macros] = "Invalid"
    patch :update, valid_params.merge(id: template.id)
    expect(response.response_code).to eq(422)
    template.reload
    expect(template.open_tracking_enabled).to eq(false)
  end

  it "should delete an email template" do
    template = email_templates.first
    expect(account.email_templates.count).to eq(3)
    delete :destroy, id: template.id
    expect(response.response_code).to eq(204)
    expect(account.email_templates.count).to eq(2)
  end

  context "payloads with from_address links" do
    it "should be able to create a template with that from address" do
      expect(account.email_templates.count).to eq(0)
      email_params = valid_params[:email_template].merge(_links: {from_address: new_from_address.id})
      post :create, { email_template: email_params }
      expect(response.response_code).to eq(201)
      expect(account.email_templates.count).to eq(1)
      expect(account.email_templates.first.from_address.id).to eq(new_from_address.id)
    end

    it "should not create a template with a from address that doesn't belong to the account" do
      expect(account.email_templates.count).to eq(0)
      email_params = valid_params[:email_template].merge(_links: {from_address: other_from_address.id})
      post :create, { email_template: email_params }
      expect(response.response_code).to eq(422)
      expect(account.email_templates.count).to eq(0)
    end

    it "should be able to update a template to use a new from address" do
      template = email_templates.first
      email_params = valid_params[:email_template].merge(_links: {from_address: new_from_address.id})
      patch :update, { email_template: email_params, id: template.id }
      expect(response.response_code).to eq(200)
      template.reload
      expect(template.from_address.id).to eq(new_from_address.id)
    end

    it "should not be able to update a template to use a from address that doesn't belong to the account" do
      template = email_templates.first
      email_params = valid_params[:email_template].merge(_links: {from_address: other_from_address.id})
      patch :update, { email_template: email_params, id: template.id }
      expect(response.response_code).to eq(422)
      template.reload
      expect(template.from_address.id).not_to eq(other_from_address.id)
    end
  end
end
