require 'rails_helper'
describe ServicesController do
  let(:account) do
    create :account,
           sms_vendor:   create(:sms_vendor),
           email_vendor: create(:email_vendor),
           voice_vendor: create(:voice_vendor),
           ipaws_vendor: create(:ipaws_vendor)
  end
  let(:user) {create :user, account: account}

  before do
    sign_in user
  end

  it 'should show services' do
    get :index
    expect(response.response_code).to eq(200)
    expect(assigns(:services)).to be == {
      self: root_path,
      keywords: keywords_path,
      command_types: command_types_path,
      inbound_sms_messages: inbound_sms_index_path,
      sms_messages: sms_index_path,
      sms_templates: templates_sms_index_path,
      email_messages: email_index_path,
      email_templates: templates_email_index_path,
      from_addresses: from_addresses_path,
      voice_messages: voice_index_path,
      incoming_voice_messages: incoming_voice_messages_path,
      ipaws_event_codes: ipaws_event_codes_path,
      ipaws_categories: ipaws_categories_path,
      ipaws_response_types: ipaws_response_types_path,
      ipaws_acknowledgement: ipaws_acknowledgement_path,
      ipaws_cog_profile: ipaws_cog_profile_path,
      ipaws_nwem_authorization: ipaws_nwem_authorization_path,
      ipaws_nwem_areas: ipaws_nwem_areas_path,
      ipaws_alerts: ipaws_alerts_path,
      webhooks: webhooks_path
    }
  end

  it 'should not allow any method other than GET' do
    post :index
    expect(response.headers).to include('Allow' => 'GET')
    expect(response.response_code).to eq(405)
  end
end
