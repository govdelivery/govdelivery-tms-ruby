require 'spec_helper'

describe 'recipients/show.rabl' do

  context 'an sms recipient' do
    let(:message) do
      stub('message', :id => 22, :to_param => 22, :class => SmsMessage)
    end
    let(:recipient) do
      stub('recipient',
           :id => 11,
           :to_param => 11,
           :message_id => 22,
           :message => message,
           :formatted_phone => '+16125551212',
           :phone => '6125551212',
           :status => RecipientStatus::SENT,
           :created_at => Time.now,
           :sent_at => Time.now,
           :error_message => nil,
           :completed_at => Time.now,
           :valid? => true)
    end


    before do
      assign(:recipient, recipient)
      assign(:content_attributes, [:phone, :formatted_phone])
      controller.stubs(:url_options).returns(:host => "test.host", :protocol => "http://", :_path_segments => {:action => "show", :controller => "recipients", :sms_id => message.id.to_s}, :script_name => "")
      render
    end
    it 'should have one item' do
      rendered.should be_json_for(recipient).
                        with_timestamps(:created_at, :completed_at).
                        with_attributes(:formatted_phone, :phone, :status).
                        with_links('sms_message' => sms_path(22), 'self' => sms_recipient_path(22, 11))
    end
  end

  context 'an email recipient' do
    let(:message) do
      stub('message', :id => 22, :to_param => 22, :class => EmailMessage)
    end
    let(:recipient) do
      stub('recipient',
           :id => 11,
           :to_param => 11,
           :message_id => 22,
           :message => message,
           :email => 'dude@bros.com',
           :status => RecipientStatus::SENT,
           :created_at => Time.now,
           :sent_at => Time.now,
           :error_message => nil,
           :completed_at => Time.now,
           :valid? => true)
    end


    before do
      assign(:recipient, recipient)
      assign(:content_attributes, [:email])
      controller.stubs(:url_options).returns(:host => "test.host", :protocol => "http://", :_path_segments => {:action => "show", :controller => "recipients", :email_id => message.id.to_s}, :script_name => "")
      render
    end
    it 'should have one item' do
      rendered.should be_json_for(recipient).
                        with_timestamps(:created_at, :completed_at).
                        with_attributes(:status, :email).
                        with_links('email_message' => email_path(22), 'self' => email_recipient_path(22, 11))
    end
  end

end
