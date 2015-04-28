require 'rails_helper'

describe 'messages/show.rabl' do
  let(:sms_vendor) { create(:sms_vendor)}
  let(:account) { create(:account, sms_vendor: sms_vendor)}
  let(:sms_message) { create(:sms_message, account: account)}
  let(:voice_message) { create(:voice_message, account: account)}
  let(:email_message) { create(:email_message, account: account)}

  it 'should work with an SMS' do
    Rabl::Engine.any_instance.stubs(:controller_name).returns('sms_messages')
    assign(:message, sms_message)
    assign(:content_attributes, [:body])
    render
    expect(rendered).to be_json_for(sms_message)
      .with_attributes(:body, :status)
      .with_timestamps(:created_at)
      .with_links('self' => sms_path(sms_message),
                  'recipients' => sms_recipients_path(sms_message),
                  'failed' => failed_sms_recipients_path(sms_message),
                  'sent' => sent_sms_recipients_path(sms_message))
  end

  it 'should work with a voice message' do
    Rabl::Engine.any_instance.stubs(:controller_name).returns('voice_messages')
    assign(:message, voice_message)
    assign(:content_attributes, [:play_url, :from_number])
    render
    expect(rendered).to be_json_for(voice_message)
      .with_attributes(:play_url, :from_number, :status)
      .with_timestamps(:created_at)
      .with_links('self' => voice_path(voice_message),
                  'recipients' => voice_recipients_path(voice_message),
                  'failed' => failed_voice_recipients_path(voice_message),
                  'sent' => sent_voice_recipients_path(voice_message),
                  'human' => human_voice_recipients_path(voice_message),
                  'machine' => machine_voice_recipients_path(voice_message),
                  'busy' => busy_voice_recipients_path(voice_message),
                  'no_answer' => no_answer_voice_recipients_path(voice_message),
                  'could_not_connect' => could_not_connect_voice_recipients_path(voice_message))
  end

  it 'should work with an email message' do
    Rabl::Engine.any_instance.stubs(:controller_name).returns('email_messages')
    assign(:message, email_message)
    assign(:content_attributes, [:from_name, :from_email, :errors_to, :reply_to, :subject, :body, :open_tracking_enabled, :click_tracking_enabled, :macros])
    render
    expect(rendered).to be_json_for(email_message)
      .with_attributes(:from_name, :from_email, :subject, :body, :status, :open_tracking_enabled, :click_tracking_enabled, :macros, :reply_to, :errors_to)
      .with_timestamps(:created_at)
      .with_links('self' => email_path(email_message),
                  'recipients' => email_recipients_path(email_message),
                  'failed' => failed_email_recipients_path(email_message),
                  'sent' => sent_email_recipients_path(email_message),
                  'opened' => opened_email_recipients_path(email_message),
                  'clicked' => clicked_email_recipients_path(email_message))
  end
end
