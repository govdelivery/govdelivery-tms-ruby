require "rails_helper"

describe 'email_templates/show.rabl' do
  let(:account) { create(:account) }
  let(:user) { create :user, account: account, admin: true }
  let(:from_address) { account.default_from_address }
  let(:email_template) { create(:email_template, account: account, user: user, from_address: from_address) }

  before do
    assign(:email_template, email_template)
  end

  it 'should work when valid' do
    render
    rendered.should be_json_for(email_template).
          with_attributes(:id, :body, :subject, :link_tracking_parameters,
                          :macros, :open_tracking_enabled, :click_tracking_enabled).
                      with_timestamps(:created_at).
                      with_links( 'self' => email_template_path(email_template),
                                  'account' => account_path(account),
                                  'from_address' => from_address_path(from_address) )
  end
end