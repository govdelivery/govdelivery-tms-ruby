require File.expand_path('../../../spec_helper', __FILE__)

describe 'inbound_messages/show.rabl' do
  let(:inbound_message) do
    stub('InboundMessage',
         id: 11,
         to_param: 11,
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
    controller.stubs(:url_options).returns(:host => "test.host", :protocol => "http://", :_path_segments => {:action => "show", :controller => "inbound_messages", :id => 11}, :script_name => "")
  end

  it 'should work' do
    render
    rendered.should be_json_for(inbound_message).
                      with_attributes(:from, :to, :body, :command_status).
                      with_timestamps(:created_at).
                      with_links('self' => inbound_sms_path(inbound_message),
                                 'command_actions' => inbound_sms_command_actions_path(inbound_message))
  end

  it "should not have command_actions if there aren't any" do
    inbound_message.stubs(:command_actions).returns([])
    render
    rendered.should be_json_for(inbound_message).
                      with_attributes(:from, :to, :body, :command_status).
                      with_timestamps(:created_at).
                      with_links('self' => inbound_sms_path(inbound_message))
  end

end
