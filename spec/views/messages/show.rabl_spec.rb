require 'spec_helper'

describe 'messages/show.rabl' do
  let(:sms_message) do
    stub('sms_message',
         :id => 22,
         :to_param => 22,
         :class => SmsMessage,
         :body => 'hi',
         :completed_at => Time.now,
         :created_at => Time.now,
         :persisted? => true,
         :status => 'new',
         :errors => []
    )
  end
  let(:voice_message) do
    stub('voice_message',
         :id => 22,
         :to_param => 22,
         :class => VoiceMessage,
         :play_url => 'bomb',
         :completed_at => Time.now,
         :created_at => Time.now,
         :persisted? => true,
         :status => 'new',
         :errors => []
    )
  end
  let(:email_message) do
    stub('email_message',
         :id => 22,
         :to_param => 22,
         :class => EmailMessage,
         :body => 'bomb',
         :subject => 'dude',
         :from_name => 'baby',
         :completed_at => Time.now,
         :created_at => Time.now,
         :persisted? => true,
         :status => 'new',
         :errors => []
    )
  end


  it 'should work with an SMS' do
    Rabl::Engine.any_instance.stubs(:controller_name).returns('sms_messages')
    assign(:message, sms_message)
    assign(:content_attributes, [:body])
    render
    rendered.should be_json_for(sms_message).
                      with_attributes(:body, :status).
                      with_timestamps(:created_at).
                      with_links('self' => sms_path(sms_message),
                                 'recipients' => sms_recipients_path(sms_message))
  end

  it 'should work with a voice message' do
    Rabl::Engine.any_instance.stubs(:controller_name).returns('voice_messages')
    assign(:message, voice_message)
    assign(:content_attributes, [:play_url])
    render
    rendered.should be_json_for(voice_message).
                      with_attributes(:play_url, :status).
                      with_timestamps(:created_at).
                      with_links('self' => voice_path(voice_message),
                                 'recipients' => voice_recipients_path(voice_message))
  end

  it 'should work with an email message' do
    Rabl::Engine.any_instance.stubs(:controller_name).returns('email_messages')
    assign(:message, email_message)
    assign(:content_attributes, [:from_name, :subject, :body])
    render
    rendered.should be_json_for(email_message).
                      with_attributes(:from_name, :subject, :body, :status).
                      with_timestamps(:created_at).
                      with_links('self' => email_path(email_message),
                                 'recipients' => email_recipients_path(email_message),
                                 'opened' => opened_email_recipients_path(email_message),
                                 'clicked' => clicked_email_recipients_path(email_message))
  end


end
