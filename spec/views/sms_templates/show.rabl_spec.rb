require 'rails_helper'

describe 'sms_templates/show.rabl' do
  let(:account) {create(:account)}
  let(:user) {create :user, account: account, admin: false}
  let(:admin_user) {create :user, account: account, admin: true}
  let(:sms_template) {create(:sms_template, account: account, user: user, uuid:"sms_template", body: 'I am an SMS template body')}

  before do
    assign(:template, sms_template)
    assign(:current_user, user)
  end

  it 'should work when valid' do
    render
    expect(rendered).to be_json_for(sms_template)
      .with_attributes(:id, :uuid, :body)
      .with_timestamps(:created_at)
      .with_links('self' => '/templates/sms/sms_template')
  end

  context "account link" do
    context "for non-admin users" do
      before do
        assign(:current_user, user)
      end

      it "should not exist" do
        render
        body = JSON.parse(rendered)
        expect(body['_links']).not_to include 'account'
      end
    end

    context "for admin users" do
      before do
        assign(:current_user, admin_user)
      end
      it "should exist" do
        render
        body = JSON.parse(rendered)
        expect(body['_links']).to include 'account'
        expect(body['_links']['account']).to eq account_path(account)
      end
    end
  end
end
