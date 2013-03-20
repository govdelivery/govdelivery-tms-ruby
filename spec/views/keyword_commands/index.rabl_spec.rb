require 'spec_helper'

describe 'keyword_commands/index.rabl' do
  let(:keyword) { stub('Keyword', id: 101) }
  let(:commands) do
    5.times.map do |i|
      stub('Command',
           id: 100,
           name: "CMD_#{i}",
           command_type: :dcm_subscribe,
           params: CommandParameters.new(:dcm_account_code => ["foo"], :dcm_topic_codes => ['XXX']),
           created_at: i.days.ago,
           updated_at: i.days.ago,
           keyword_id: 101,
           errors: [],
           command_actions: []
      )
    end
  end

  before do
    assign(:commands, commands)
    assign(:keyword, keyword)
    controller.stubs(:url_options).returns(:host => "test.host", :protocol => "http://", :_path_segments => {:action => "show", :controller => "commands", :keyword_id => 2}, :script_name => "")
    render
    @json = ActiveSupport::JSON.decode(rendered)
  end
  it 'should have one item' do
    rendered.should have_json_type(Array)
    rendered.should have_json_size(5)
  end
end
