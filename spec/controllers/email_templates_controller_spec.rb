require 'rails_helper'

describe EmailTemplatesController do
  let(:account) {create(:account)}
  let(:other_account) {create(:account)}
  let(:user) {create :user, account: account, admin: false}
  let(:admin_user) {create :user, account: account, admin: true}
  let(:from_address) {account.default_from_address}
  let(:new_from_address) {create(:from_address, account: account)}
  let(:other_from_address) {create(:from_address, account: other_account)}
  let(:email_templates) {create_list(:email_template, 3, account: account, user: user, from_address: from_address)}
  let(:template) {email_templates.first}
  let(:valid_params) do
    {
      body: '<html><body>[HELLO]</body></html>',
      subject: 'This is a test',
      link_tracking_parameters: 'tracking=param&one=two',
      macros: {'HELLO' => 'WORLD'},
      click_tracking_enabled: true,
      open_tracking_enabled: true,
    }
  end
  let(:model) {EmailTemplate}

  before do
    sign_in user
  end

  it_should_have_a_pageable_index(:email_templates)

  it 'should find a template that does exist' do
    get :show, uuid: template.uuid
    expect(response.response_code).to eq(200)
  end

  it 'should not find a template that does not exist' do
    get :show, uuid: "no_template_here"
    expect(response.response_code).to eq(404)
  end

  it 'should create an email template' do
    expect(account.email_templates.count).to eq(0)
    post :create, email_template: valid_params.merge(uuid: "fancy-email-template")
    expect(response.response_code).to eq(201)
    expect(account.email_templates.count).to eq(1)
  end

  it 'should not create invalid email templates' do
    expect(account.email_templates.count).to eq(0)
    valid_params.delete(:subject)
    post :create, email_template: valid_params
    expect(response.response_code).to eq(422)
    expect(account.email_templates.count).to eq(0)
  end

  it 'should update an email template' do
    expect(template.open_tracking_enabled).to eq(false)
    patch :update, uuid: template.uuid, email_template: valid_params
    expect(response.response_code).to eq(200)
    template.reload
    expect(template.open_tracking_enabled).to eq(true)
  end

  it 'should not update an email template id' do
    original_template_id = template.id
    patch :update, uuid: template.uuid, email_template: valid_params.merge(id: 8_820_123)
    expect(response.response_code).to eq(200)
    template.reload
    expect(template.id).to eq(original_template_id)
  end

  it 'should not update an email template uuid' do
    original_template_uuid = template.uuid
    patch :update, uuid: template.uuid, email_template: valid_params.merge(uuid: "new-template-name")
    expect(response.response_code).to eq(422)
    template.reload
    expect(template.uuid).to eq(original_template_uuid)
  end

  it 'should not update an email template to an invalid state' do
    expect(template.open_tracking_enabled).to eq(false)
    valid_params[:macros] = 'Invalid'
    patch :update, uuid: template.uuid, email_template: valid_params
    expect(response.response_code).to eq(422)
    template.reload
    expect(template.open_tracking_enabled).to eq(false)
  end

  it 'should delete an email template' do
    email_templates # We have to create email_templates before there are email_templates
    expect(account.email_templates.count).to eq(3)
    delete :destroy, uuid: template.uuid
    expect(response.response_code).to eq(204)
    expect(account.email_templates.count).to eq(2)
  end

  context 'payloads with from_address links' do
    it 'should be able to create a template with that from address' do
      expect(account.email_templates.count).to eq(0)
      post :create, email_template: valid_params.merge(_links: {from_address: new_from_address.id}).merge(uuid: "new-email-template")
      expect(response.response_code).to eq(201)
      expect(account.email_templates.count).to eq(1)
      expect(account.email_templates.first.from_address.id).to eq(new_from_address.id)
    end

    it "should not create a template with a from address that doesn't belong to the account" do
      expect(account.email_templates.count).to eq(0)
      post :create, email_template: valid_params.merge(_links: {from_address: other_from_address.id})
      expect(response.response_code).to eq(422)
      expect(account.email_templates.count).to eq(0)
    end

    it 'should be able to update a template to use a new from address' do
      patch :update, uuid: template.uuid, email_template: valid_params.merge(_links: {from_address: new_from_address.id})
      expect(response.response_code).to eq(200)
      template.reload
      expect(template.from_address.id).to eq(new_from_address.id)
    end

    it "should not be able to update a template to use a from address that doesn't belong to the account" do
      patch :update, uuid: template.uuid, email_template: valid_params.merge(_links: {from_address: other_from_address.id})
      expect(response.response_code).to eq(422)
      template.reload
      expect(template.from_address.id).not_to eq(other_from_address.id)
    end
  end

  context 'with a message type' do
    render_views
    it 'accepts message_type as a string' do
      mt_params = valid_params.merge(message_type_code: 'salutations')
      post :create, email_template: mt_params
      expect(response.response_code).to eq(201)
      expect(response.body).to include('salutations')
    end

    it 'does not accept message_type_label without message_type_code' do
      mt_params = valid_params.merge(message_type_label: 'nope')
      post :create, email_template: mt_params
      expect(response.response_code).to eq(422)
      expect(assigns(:template).errors[:message_type_label]).to be_present
      expect(response.body).to include('Message type code is required.')
    end
  end
end
