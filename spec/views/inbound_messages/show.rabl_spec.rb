require File.expand_path('../../../rails_helper', __FILE__)

describe 'inbound_messages/show.rabl' do
  let(:inbound_message) do
    stub('InboundMessage',
         id: 11,
         to_param: '11',
         from: '+15551112222',
         to: '+15551113333',
         body: 'BODY',
         command_actions: [stub],
         command_status: 'success',
         created_at: 4.days.ago
        )
  end

  before do
    assign(:message, inbound_message)
    Rabl::Engine.any_instance.expects(:url_for).with(has_entries(controller: 'inbound_messages', id: 11)).returns(inbound_sms_path(inbound_message))
  end

  it 'should work' do
    render
    expect(rendered).to be_json_for(inbound_message)
      .with_attributes(:from, :to, :body, :command_status)
      .with_timestamps(:created_at)
      .with_links('self' => inbound_sms_path(inbound_message),
                  'command_actions' => inbound_sms_command_actions_path(inbound_message))
  end

  it "should not have command_actions if there aren't any" do
    inbound_message.stubs(:command_actions).returns([])
    render
    expect(rendered).to be_json_for(inbound_message)
      .with_attributes(:from, :to, :body, :command_status)
      .with_timestamps(:created_at)
      .with_links('self' => inbound_sms_path(inbound_message))
  end
end
