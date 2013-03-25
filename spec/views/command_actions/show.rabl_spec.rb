require File.expand_path('../../../spec_helper', __FILE__)

describe 'command_actions/show.rabl' do
  let(:command_action) do
    stub('CommandAction',
         id: 1,
         inbound_message_id: 2,
         command_id: 1,
         command: stub(keyword_id: 3, keyword: stub(id: 3)),
         response_body: 'http body',
         status: 200,
         content_type: 'text/plain',
         created_at: Time.now.beginning_of_day,
    )
  end


  before do
    assign(:command_action, command_action)
  end

  it 'should work when valid' do
    render
    rendered.should be_json_for(command_action).
                      with_attributes(:status, :content_type, :response_body).
                      with_timestamps(:created_at).
                      with_links('self' => inbound_sms_command_action_path(command_action.inbound_message_id, command_action.id),
                                 'inbound_sms_message' => inbound_sms_path(command_action.inbound_message_id),
                                 'command' => keyword_command_path(command_action.command.keyword_id, command_action.command_id))
  end

end
