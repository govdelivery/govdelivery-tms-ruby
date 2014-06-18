require 'spec_helper'

describe ForwardWorker do
  let(:account){ create(:account_with_sms) }
  let(:command){ create(:forward_command, keyword: account.default_keyword) }
  let(:options) { {url: "url",
                   http_method: "post",
                   username: nil,
                   password: nil,
                   from: "333",
                   sms_body: "sms body",
                   sms_tokens: ["sms", "body", "tokens"],
                   account_id: account.id,
                   command_id: command.id,
                   inbound_message_id: create(:inbound_message),
                   callback_url: "http://localhost",
                   sms_body_param_name: "sms_body_d",
                   from_param_name: "from_param"} }

  it 'creates one Twilio::SenderWorker job if command.process_response returns a message' do
    Service::TwilioMessageService.expects(:deliver!).with( kind_of(SmsMessage), options[:callback_url] )
    command.expects(:process_response).returns( SmsMessage.new )
    subject.expects(:command).returns(command)
    # this is a pretty worthless test. The super calls in :perform and :process_response are getting in the way of stubbing them.
    subject.perform( options )
  end

end
