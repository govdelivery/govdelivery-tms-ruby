require File.expand_path("../../little_spec_helper", __FILE__)
require 'spec_helper'

describe ForwardWorker do
  let(:options) { {url: "url",
                   http_method: "post",
                   username: nil,
                   password: nil,
                   from: "333",
                   sms_body: "sms body",
                   sms_tokens: ["sms", "body", "tokens"],
                   account_id: 1,
                   command_id: 1,
                   callback_url: "http://localhost",
                   sms_body_param_name: "sms_body_d",
                   from_param_name: "from_param"} }

  it 'creates one Twilio::SenderWorker job if command.process_response returns a message' do
    pending("whatever I'll fix this bs later")
    Service::ForwardService.any_instance.expects(:send)
    Twilio::SenderWorker.expects(:do_deliver).once
    fake_command = build(:forward_command).tap{ |c|  c.expects(:process_response).returns( build(:sms_message).tap{ |m| m.expects(:sending!) }) }
    subject.expects( :command ).returns(fake_command)
    subject.expects( :account ).returns(stub('account'))

    subject.perform( options )
  end

end
