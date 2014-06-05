require 'spec_helper'

describe CommandType::Forward do
  let(:account) { stub_everything('account', sms_messages: stub(:new => SmsMessage.new)) }
  let(:command_action) { stub('CommandAction',
                              content_type: 'text/plain',
                              response_body: "ATLANTA IS FULL OF ZOMBIES, STAY AWAY",
                              plaintext_body?: true,
                              save!: true) }
  let(:http_response) { OpenStruct.new(:body => "ATLANTA IS FULL OF ZOMBIES, STAY AWAY",
                                       :status => 200,
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
                          :inbound_message_id => 111,
                          :from_param_name => 'uzer',
                          :sms_body_param_name => 'teh_sms_body')
  end

  subject { CommandType::Forward.new }

  before do
    stub_command_action_create!(command_params, http_response, command_action)
  end

  it 'creates a command response and sms message' do
    SmsMessage.any_instance.expects(:save!).returns(true)
    command_action.stubs(:success?).returns(true)

    subject.process_response(account, command_params, http_response)
  end

  it 'will not create an sms message if command_action is not successfull' do
    command_action.stubs(:success?).returns(false)
    subject.expects(:build_message).never
    subject.process_response(account, command_params, http_response)
  end

  it 'will not create an sms message if command_action.content_type does not match expected_content_type' do
    command_action.stubs(:content_type).returns('something crazy')
    subject.expects(:build_message).never
    subject.process_response(account, command_params, http_response)
  end

  it 'will return an sms message if command_action.content_type matches the expected_content_type' do
    command_action.stubs(:success?).returns(true)
    command_action.stubs(:content_type).returns('text/plain')
    subject.expects(:build_message).once
    subject.process_response(account, command_params, http_response)
  end

end
