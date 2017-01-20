require 'rails_helper'

describe SmsTemplatesController do
  let(:account) {create(:account)}
  let(:user) {create :user, account: account, admin: false}
  let(:sms_templates) {create_list(:sms_template, 3, account: account, user: user)}
  let(:template) {sms_templates.first}
  let(:valid_params) do
    {
      body: 'Hello, world!'
    }
  end
  let(:model) {SmsTemplate}

  before do
    sign_in user
  end

  it_should_have_a_pageable_index(:sms_templates)

  it 'should find a template that does exist' do
    get :show, uuid: template.uuid
    expect(response.response_code).to eq(200)
  end

  it 'should not find a template that does not exist' do
    get :show, uuid: "no_template_here"
    expect(response.response_code).to eq(404)
  end

  it 'should create an sms template' do
    expect(account.sms_templates.count).to eq(0)
    post :create, sms_template: {body: "New", uuid: "fancy-new"}
    expect(response.response_code).to eq(201)
    expect(account.sms_templates.count).to eq(1)
  end

  it 'should not create invalid sms templates' do
    expect(account.sms_templates.count).to eq(0)
    valid_params.delete(:subject)
    post :create, sms_template: { body: nil }
    expect(response.response_code).to eq(422)
    expect(account.sms_templates.count).to eq(0)
  end

  it 'should update an sms template' do
    expect(template.body).not_to eq(valid_params[:body])
    patch :update, uuid: template.uuid, sms_template: valid_params
    expect(response.response_code).to eq(200)
    template.reload
    expect(template.body).to eq(valid_params[:body])
  end

  it 'should not update an sms template to an invalid state' do
    patch :update, uuid: template.uuid, sms_template: {body: nil}
    expect(response.response_code).to eq(422)
    template.reload
    expect(template.body).not_to be_nil
  end

  it 'should not update an sms template id' do
    original_id = template.id
    patch :update, uuid: template.uuid, sms_template: valid_params.merge({id: 1000000})
    expect(response.response_code).to eq(200)
    template.reload
    expect(template.id).to eql(original_id)
  end

  it 'should not update an sms template uuid' do
    original_uuid = template.uuid
    patch :update, uuid: template.uuid, sms_template: valid_params.merge({uuid: "new-uid"})
    expect(response.response_code).to eq(422)
    template.reload
    expect(template.uuid).to eql(original_uuid)
  end

  it 'should delete an sms template' do
    sms_templates   # We have to create sms_templates before there are sms_templates
    expect(account.sms_templates.count).to eq(3)
    delete :destroy, uuid: template.uuid
    expect(response.response_code).to eq(204)
    expect(account.sms_templates.count).to eq(2)
  end
end