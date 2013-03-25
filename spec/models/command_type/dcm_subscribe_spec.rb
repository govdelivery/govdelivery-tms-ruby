require 'spec_helper'

describe CommandType::DcmSubscribe do
  let(:account) { stub_everything('account') }
  let(:command_action) { stub('CommandAction', content_type: 'text/plain', save!: true) }
  let(:http_response) { OpenStruct.new(
    :body => "ATLANTA IS FULL OF ZOMBIES, STAY AWAY",
    :status => 200,
    :headers => {'Content-Type' => 'text/plain'}
  ) }
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
    stub_command_action_create!(command_params, http_response, command_action)
    subject.process_response(account, command_params, http_response)
  end

end
