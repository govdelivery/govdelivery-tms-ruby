# -*- coding: utf-8 -*-
require 'rails_helper'

describe CommandType::DcmUnsubscribe do
  let(:account) { stub_everything('account') }
  let(:command_action) { stub('CommandAction', content_type: 'text/plain', save!: true) }
  let(:http_response) { OpenStruct.new(body: {'message'=> "ATLANTA IS FULL OF ZOMBIES, STAY AWAY"},
                                       status: 200,
                                       headers: {'Content-Type' => 'text/plain'}) }
  let(:command_params) do
    CommandParameters.new(url: "url",
                          http_method: "post",
                          username: nil,
                          password: nil,
                          from: "333",
                          sms_body: "sms body",
                          account_id: account.id,
                          command_id: 11,
                          inbound_message_id: 111)
  end

  subject { CommandType::DcmUnsubscribe.new }

  it 'creates a command response and sms message' do
    stub_command_action_create!(command_params, http_response, command_action, http_response.body.to_json)
    subject.process_response(account, command_params, http_response)
  end

  it 'can be created through the account' do
    account = create(:account_with_sms, dcm_account_codes: ['xyz', 'uvw'])
    account.create_command!('stop',
                            command_type: 'dcm_unsubscribe', params: {dcm_account_codes: ['xyz','uvw'] } )
    account.create_command!('désabonner',
                            command_type: 'dcm_unsubscribe', params: {dcm_account_codes: ['xyz','uvw'] } )

  end

end
