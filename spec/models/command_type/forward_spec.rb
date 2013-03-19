require 'spec_helper'

describe CommandType::Forward do
  let(:account) { stub_everything('account', sms_messages: stub(:new => SmsMessage.new)) }
  let(:command_action) { CommandAction.new(http_content_type: 'text/plain',
                                           http_body: "ATLANTA IS FULL OF ZOMBIES, STAY AWAY") }
  let(:http_response) { stub('faraday http response',
                             :body => "ATLANTA IS FULL OF ZOMBIES, STAY AWAY",
                             :code => 200,
                             :headers => {'Content-Type' => 'text/plain'}) }
  let(:command_params) do
    CommandParameters.new(:url => "url",
                          :http_method => "post",
                          :username => nil,
                          :password => nil,
                          :from => "333",
                          :sms_body => "sms body",
                          :account_id => account.id,
                          :command_id => 11,
                          :inbound_message_id => 111)
  end

  subject { CommandType::Forward.new }

  it 'creates a command response and sms message' do
    SmsMessage.any_instance.expects(:save!).returns(true)
    command_action.stubs(:plaintext_body?).returns(true)
    CommandAction.expects(:create!).with(inbound_message_id: command_params.inbound_message_id,
                                           command_id: command_params.command_id,
                                           http_response_code: http_response.code,
                                           http_response_type: http_response.headers['Content-Type'],
                                           http_body: http_response.body).returns(command_action)
    subject.process_response(account, command_params, http_response)
  end

  it 'will not create an sms message if response type is wrong' do
    command_action.stubs(:plaintext_body?).returns(false)
    CommandAction.expects(:create!).with(inbound_message_id: command_params.inbound_message_id,
                                           command_id: command_params.command_id,
                                           http_response_code: http_response.code,
                                           http_response_type: http_response.headers['Content-Type'],
                                           http_body: http_response.body).returns(command_action)
    subject.expects(:build_message).never
    subject.process_response(account, command_params, http_response)
  end

  it 'leaves body null if it is too long' do
    http_response.stubs(:body).returns('too long')
    command_action.stubs(:plaintext_body?).returns(false)
    SmsMessage.any_instance.expects(:save!).never
    CommandAction.expects(:create!).with(inbound_message_id: command_params.inbound_message_id,
                                           command_id: command_params.command_id,
                                           http_response_code: http_response.code,
                                           http_response_type: http_response.headers['Content-Type'],
                                           http_body: 'too long').returns(command_action)
    subject.process_response(account, command_params, http_response)
  end


end
