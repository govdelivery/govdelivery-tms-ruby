require 'rails_helper'

describe CommandWorkers::ForwardWorker do
  let(:account){ create(:account_with_sms) }
  let(:command) do
    keyword = account.keywords.create(name: 'worker')
    create(:forward_command,
           keyword: keyword,
           params:  {
             url:                 "http://dudes.ruby",
             http_method:         "post",
             username:            nil,
             password:            nil,
           })
  end

  let(:options) do
    {
      command_id:         command.id,
      from:               "333",
      sms_body:           "sms body",
      sms_tokens:         ["sms", "body", "tokens"],
      inbound_message_id: create(:inbound_message).id,
      callback_url:       "http://localhost",
    }
  end

  let(:http_response) do
    stub('http_response',
         status:  200,
         headers: {'Content-Type' => 'andrew/json'},
         body:    'foo')
  end

  it 'creates one Twilio::SenderWorker job if command.process_response returns a message' do
    Service::ForwardService.any_instance.expects(:send).returns(http_response)
    Twilio::SenderWorker.expects(:perform_async).once
    sms_message = build(:sms_message).tap { |m|
      m.expects(:responding!)
      m.expects(:first_recipient_id).returns(1)
    }
    Command.any_instance.expects(:process_response).returns(sms_message)

    subject.perform( options )
  end

  it 'does not create a Twilio::SenderWorker job if command.process_response does not return a message' do
    Service::ForwardService.any_instance.expects(:send).returns(http_response)
    Twilio::SenderWorker.expects(:perform_async).never
    # this craziness is due to the use of super in the perform method
    Command.any_instance.expects(:process_response).returns(nil)
    subject.perform( options )
  end

end
