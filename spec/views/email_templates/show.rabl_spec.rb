require 'rails_helper'

describe 'email_templates/show.rabl' do
  let(:account) {create(:account)}
  let(:user) {create :user, account: account, admin: false}
  let(:admin_user) {create :user, account: account, admin: true}
  let(:from_address) {account.default_from_address}
  let(:email_template) {create(:email_template, account: account, user: user, from_address: from_address, uuid: 'email_template')}

  before do
    assign(:template, email_template)
    assign(:current_user, user)
  end

  it 'should work when valid' do
    render
    expect(rendered).to be_json_for(email_template)
      .with_attributes(:id, :uuid, :body, :subject, :link_tracking_parameters,
                       :macros, :open_tracking_enabled, :click_tracking_enabled)
      .with_timestamps(:created_at)
      .with_links('self' => '/templates/email/email_template',
                  'from_address' => from_address_path(from_address))
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
