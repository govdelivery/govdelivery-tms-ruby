require 'rails_helper'

describe CommandWorkers::ForwardWorker do
  let(:account) { create(:account_with_sms, sms_vendor: create(:sms_vendor, worker: 'KahloMessageWorker')) }
  let(:command) do
    keyword = account.keywords.create(name: 'worker')
    create(:forward_command,
           keyword: keyword,
           params:  {
             url:                 'http://dudes.ruby',
             http_method:         'post',
             username:            nil,
             password:            nil
           })
  end

  let(:options) do
    {
      command_id:         command.id,
      to:                 '111', 
      from:               '333',
      sms_body:           'sms body',
      sms_tokens:         %w(sms body tokens),
      inbound_message_id: create(:inbound_message).id,
      callback_url:       'http://localhost'
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
    account.sms_vendor.worker.constantize.expects(:perform_async).once
    sms_message = build(:sms_message, account: account).tap do |m|
      m.expects(:responding!)
      m.expects(:first_recipient_id).returns(1)
    end
    Command.any_instance.expects(:process_response).returns(sms_message)

    subject.perform(options)
  end

  it 'does not create a Twilio::SenderWorker job if command.process_response does not return a message' do
    Service::ForwardService.any_instance.expects(:send).returns(http_response)
    Twilio::SenderWorker.expects(:perform_async).never
    # this craziness is due to the use of super in the perform method
    Command.any_instance.expects(:process_response).returns(nil)
    subject.perform(options)
  end

  context 'when an exception occurs' do
    before do
      expect(command.command_actions.count).to eq 0
    end

    it 'reraises the exception if it is a Faraday::ClientError with a response' do
      subject.stubs(:send_request).raises(Faraday::ClientError.new(StandardError.new('foo'), response_headers))
      expect {subject.perform(options)}.to raise_error(Faraday::ClientError)
      expect(command.command_actions.count).to eq 1
      expect(command.command_actions.first.status).to eq 418
    end

    it 'reraises the exception if it is a Faraday::ClientError with no response' do
      subject.stubs(:send_request).raises(Faraday::ClientError, StandardError.new('bar'))
      expect {subject.perform(options)}.to raise_error(Faraday::ClientError)
      expect(command.command_actions.count).to eq 1
      expect(command.command_actions.first.error_message).to eq 'bar'
    end

    it 'raises a Sidekiq::Retries::Fail if it is not a Faraday::ClientError in order to fail the job immediately' do
      subject.stubs(:send_request).raises(StandardError)
      expect {subject.perform(options)}.to raise_error(Sidekiq::Retries::Fail)
      expect(command.command_actions.count).to eq 0
    end
  end

  def response_headers
    {status: '418', headers: {'content-type' => 'text/gooo'}, body: 'not really a teapot'}
  end
end
