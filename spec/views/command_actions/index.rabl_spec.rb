require 'spec_helper'

describe 'command_actions/index.rabl' do
  let(:command_actions) do
    5.times.map do |i|
      stub('CommandAction',
           id: 1,
           inbound_message_id: 2,
           command_id: 1,
           command: stub(keyword_id: 3, keyword: stub(id: 3)),
           response_body: 'http body',
           status: 200,
           content_type: 'text/plain',
           created_at: Time.now.beginning_of_day
      )
    end
  end

  before do
    assign(:command_actions, command_actions)
    controller.stubs(:url_options).returns(:host => "test.host", :protocol => "http://", :_path_segments => {:action => "show", :controller => "command_actions", :sms_id => 2}, :script_name => "")
    render
    @json = ActiveSupport::JSON.decode(rendered)
  end
  it 'should have one item' do
    rendered.should have_json_type(Array)
    rendered.should have_json_size(5)
  end
end
