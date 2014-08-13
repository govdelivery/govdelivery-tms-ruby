require File.expand_path('../../../rails_helper', __FILE__)

describe 'recipients/show.rabl' do

  context 'an sms recipient' do
    let(:message) do
      stub('message', id: 22, to_param: '22', class: SmsMessage)
    end
    let(:recipient) do
      stub('recipient',
           id: 11,
           to_param: '11',
           message_id: 22,
           message: message,
           formatted_phone: '+16125551212',
           phone: '6125551212',
           status: 'sent',
           created_at: Time.now,
           sent_at: Time.now,
           error_message: nil,
           completed_at: Time.now,
           valid?: true)
    end


    before do
      assign(:recipient, recipient)
      Rabl::Engine.any_instance.expects(:url_for).with(has_entries(controller: 'sms_messages', id: 22)).returns(sms_path(22))
      Rabl::Engine.any_instance.expects(:url_for).with(has_entries(controller: 'recipients', id: 11)).returns(sms_recipient_path(22, 11))
      assign(:content_attributes, [:phone, :formatted_phone])
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
      stub('message', id: 22, to_param: '22', class: EmailMessage)
    end
    let(:recipient) do
      stub('recipient',
           id: 11,
           to_param: '11',
           message_id: 22,
           message: message,
           email: 'dude@bros.com',
           status: 'sent',
           created_at: Time.now,
           sent_at: Time.now,
           error_message: nil,
           completed_at: Time.now,
           macros: {"name" => "Henry Hankson"},
           valid?: true)
    end


    before do
      assign(:recipient, recipient)
      Rabl::Engine.any_instance.expects(:url_for).with(has_entries(controller: 'email_messages', id: 22)).returns(email_path(22)).at_least_once
      Rabl::Engine.any_instance.expects(:url_for).with(has_entries(controller: 'recipients', id: 11)).returns(email_recipient_path(22, 11)).at_least_once
      assign(:content_attributes, [:email, :macros])
      render
    end
    it 'should have one item' do
      rendered.should be_json_for(recipient).
                        with_timestamps(:created_at, :completed_at).
                        with_attributes(:status, :email, :macros).
                        with_links('email_message' => email_path(22), 'self' => email_recipient_path(22, 11))
    end

    it 'should not have an error_message' do
      json_data = ActiveSupport::JSON.decode(rendered)
      json_data.should_not have_key(:error_message)
    end

    context 'with an error message' do
      it 'should have an error_message if present' do
        assign(:recipient, recipient.tap{|r| r.stubs(:error_message).returns('oops')})
        json_data = ActiveSupport::JSON.decode(render)
        json_data.should include('error_message' => 'oops')
      end
    end
  end
end
