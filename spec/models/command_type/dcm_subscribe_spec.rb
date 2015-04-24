require 'rails_helper'

describe CommandType::DcmSubscribe do
  let(:account) {stub_everything('account')}
  let(:command_action) {stub('CommandAction', content_type: 'text/plain', save!: true)}
  let(:http_response) do
    OpenStruct.new(
      body: 'ATLANTA IS FULL OF ZOMBIES, STAY AWAY',
      status: 200,
      headers: {'Content-Type' => 'text/plain'}
    )
  end
  let(:command_params) do
    CommandParameters.new(url: 'url',
                          http_method: 'post',
                          username: nil,
                          password: nil,
                          from: '333',
                          sms_body: 'sms body',
                          account_id: account.id,
                          command_id: 11,
                          inbound_message_id: 111)
  end

  subject {CommandType::DcmSubscribe.new}

  it 'creates a command response and sms message' do
    stub_command_action_create!(command_params, http_response, command_action)
    subject.process_response(account, command_params, http_response)
  end

  it 'can be created through the account' do
    account = create(:account_with_sms, dcm_account_codes: %w(xyz uvw))
    account.create_command!('subscribe',
                            command_type: 'dcm_subscribe', params: {dcm_account_code: 'xyz', dcm_topic_codes: ['abc']})
    # if the account has multiple dcm_account_codes create another command to subscribe to both at once
    account.create_command!('subscribe',
                            command_type: 'dcm_subscribe', params: {dcm_account_code: 'uvw', dcm_topic_codes: ['def']})
  end
end
