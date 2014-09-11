require 'rails_helper'
require_relative '../../../app/transformers/eta_spot'

describe CommandWorkers::ForwardWorker do
  let(:account){ create(:account_with_sms) }
  let(:command){ create(:forward_command, keyword: account.default_keyword) }
  let(:options) { {url: "http://dudes.ruby",
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
    Service::ForwardService.any_instance.expects(:send)
    Twilio::SenderWorker.expects(:perform_async).once
    # this craziness is due to the use of super in the perform method
    fake_command = build(:forward_command).tap{ |c|
      c.expects(:process_response).
        returns( build(:sms_message).tap{ |m|
                  m.expects(:responding!)
                  m.expects(:first_recipient_id).returns(1)
                })
    }
    subject.expects( :command ).returns(fake_command)
    subject.expects( :account ).returns(stub('account'))

    subject.perform( options )
  end

  it 'does not create a Twilio::SenderWorker job if command.process_response does not return a message' do
    Service::ForwardService.any_instance.expects(:send)
    Twilio::SenderWorker.expects(:perform_async).never
    # this craziness is due to the use of super in the perform method
    fake_command = build(:forward_command).tap{ |c|
      c.expects(:process_response).
        returns( nil )
    }
    subject.expects( :command ).returns(fake_command)
    subject.expects( :account ).returns(stub('account'))

    subject.perform( options )
  end

  it 'does not create a Twilio::SenderWorker job if command.process_response blows up' do
    Service::ForwardService.any_instance.expects(:send)
    Twilio::SenderWorker.expects(:perform_async).never
    # this craziness is due to the use of super in the perform method
    fake_command = build(:forward_command).tap { |c|
      c.expects(:process_response).
        raises(::Transformers::InvalidResponse, 'whoops')
    }
    subject.expects(:command).returns(fake_command)
    subject.expects(:account).returns(stub('account'))

    subject.perform(options)
  end

end
