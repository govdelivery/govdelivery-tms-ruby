require 'rails_helper'

describe CommandType::Forward do

  let(:account) { stub_everything('account', sms_messages: stub(new: SmsMessage.new)) }
  let(:command_action) { stub('CommandAction',
                              content_type:    'text/plain',
                              response_body:   "ATLANTA IS FULL OF ZOMBIES, STAY AWAY",
                              plaintext_body?: true,
                              save!:           true) }
  let(:http_response) { OpenStruct.new(body: 'ATLANTA IS FULL OF ZOMBIES, STAY AWAY',
                                       status: 200,
                                       headers: {'Content-Type' => 'text/plain'}) }
  let(:http_error_response) { OpenStruct.new(nil) }

  let(:command_params) do
    CommandParameters.new({url:                 "url",
                           http_method:         "post",
                           username:            nil,
                           password:            nil,
                           from:                "333",
                           sms_body:            "sms body",
                           account_id:          account.id,
                           command_id:          11,
                           inbound_message_id:  111,
                           from_param_name:     'uzer',
                           sms_body_param_name: 'teh_sms_body'})
  end

  subject { CommandType::Forward.new }

  context 'on HTTP error' do
    before do
      stub_command_action_create!(command_params, http_error_response, command_action)
      command_action.stubs(:success?).returns(false)
    end

    it 'should not create an sms' do
      subject.expects(:build_message).never
      subject.process_response(account, command_params, http_error_response)
    end
  end

  context 'on network error' do
    before do
      stub_command_action_error!(command_params, command_action, "oh crap")
      command_action.stubs(:success?).returns(false)
    end

    it 'should not create an sms' do
      subject.expects(:build_message).never
      subject.process_error(command_params, "oh crap")
    end
  end

  context 'on success' do

    before do
      stub_command_action_create!(command_params, http_response, command_action)
    end

    it 'creates a command response and sms message' do
      SmsMessage.any_instance.expects(:save!).returns(true)
      command_action.stubs(:success?).returns(true)

      subject.process_response(account, command_params, http_response)
    end

    it 'will not create an sms message if command_action is not successful' do
      command_action.stubs(:success?).returns(false)
      subject.expects(:build_message).never
      subject.process_response(account, command_params, http_response)
    end

    it 'will not create an sms message if command_action.content_type does not match text/plain' do
      command_action.stubs(:content_type).returns('something crazy')
      command_action.stubs(:success?).returns(true)
      subject.expects(:build_message).never
      subject.process_response(account, command_params, http_response)
    end

    it 'will return an sms message if command_action.content_type matches text/plain' do
      command_action.stubs(:success?).returns(true)
      command_action.stubs(:content_type).returns('text/plain')
      subject.expects(:build_message).once
      subject.process_response(account, command_params, http_response)
    end
  end
end
