require 'spec_helper'

describe CommandType::DcmSubscribe do
  let(:account) { stub_everything('account') }
  let(:command_action) { CommandAction.new(http_content_type: 'text/plain') }
  let(:http_response) { {
    :body => "ATLANTA IS FULL OF ZOMBIES, STAY AWAY",
    :status => 200,
    :headers => {'Content-Type' => 'text/plain'}
  } }
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

  subject { CommandType::DcmSubscribe.new }

  it 'creates a command response and sms message' do
    CommandAction.expects(:create!).with(inbound_message_id: command_params.inbound_message_id,
                                         command_id: command_params.command_id,
                                         http_response_code: http_response[:status],
                                         http_content_type: http_response[:headers]['Content-Type'],
                                         http_body: http_response[:body]).returns(command_action)
    subject.process_response(account, command_params, http_response)
  end

end
