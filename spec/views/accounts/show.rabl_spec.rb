require File.expand_path('../../../rails_helper', __FILE__)

describe 'accounts/show.rabl' do
  let(:sms_vendor) { create(:sms_vendor) }
  let(:voice_vendor) { create(:voice_vendor) }
  let(:email_vendor) { create(:email_vendor) }
  let(:ipaws_vendor) { create(:ipaws_vendor) }

  let(:account) do
    create(:account,
           sms_vendor:        sms_vendor,
           voice_vendor:      voice_vendor,
           ipaws_vendor:      ipaws_vendor,
           email_vendor:      email_vendor,
           dcm_account_codes: ['so', 'rad'])
  end


  before do
    assign(:account, account)
  end

  it 'should work when valid' do
    render
    rendered.should be_json_for(account).
                      with_attributes(:name,
                                      :stop_handler_id,
                                      :voice_vendor_id,
                                      :email_vendor_id,
                                      :sms_vendor_id,
                                      :ipaws_vendor_id,
                                      :help_text,
                                      :stop_text,
                                      :default_response_text).
                      with_arrays(:dcm_account_codes).
                      with_timestamps(:created_at, :updated_at).
                      with_links('self' => account_path(account))
  end

end
