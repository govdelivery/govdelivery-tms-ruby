require 'spec_helper'
describe ServicesController do

  it "should show services" do
    account = create :account,
      sms_vendor: create(:sms_vendor),
      email_vendor: create(:email_vendor),
      voice_vendor: create(:voice_vendor),
      ipaws_vendor: create(:ipaws_vendor)
    user = create :user, account: account
    sign_in user
    get :index
    response.response_code.should == 200
    expect(assigns(:services)).to be == {
      self: root_path,
      keywords: keywords_path,
      command_types: command_types_path,
      inbound_sms_messages: inbound_sms_index_path,
      sms_messages: sms_index_path,
      email_messages: email_index_path,
      voice_messages: voice_index_path,
      ipaws_event_codes: ipaws_event_codes_path,
      ipaws_categories: ipaws_categories_path,
      ipaws_response_types: ipaws_response_types_path
    }.stringify_keys
  end

  it "should not allow any method other than GET" do
    account = create :account
    user = create :user, account: account
    sign_in user
    post :index
    response.headers.should include('Allow' => 'GET')
    response.response_code.should == 405
  end

end
