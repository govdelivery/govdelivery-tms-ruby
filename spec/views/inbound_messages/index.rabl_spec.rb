require 'spec_helper'

describe 'inbound_messages/index.rabl' do
  let(:messages) do
    5.times.map do |i|
      stub('InboundMessage',
           id: 11,
           from: '+15551112222',
           to: '+15551113333',
           body: 'BODY',
           command_status: 'success',
           created_at: i.days.ago,
           command_actions: [stub]
      )
    end
  end

  before do
    assign(:messages, messages)
    controller.stubs(:url_options).returns(:host => "test.host", :protocol => "http://", :_path_segments => {:action => "show", :controller => "inbound_messages"}, :script_name => "")
    render
    @json = ActiveSupport::JSON.decode(rendered)
  end
  it 'should have one item' do
    rendered.should have_json_type(Array)
    rendered.should have_json_size(5)
  end
end
