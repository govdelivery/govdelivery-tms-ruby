require File.expand_path('../../../spec_helper', __FILE__)

describe 'keyword_commands/show.rabl' do
  let(:keyword) { stub('Keyword', to_param: 101) }
  let(:command) do
    stub('Command',
         id: 100,
         to_param: 100,
         name: "MOMS",
         command_type: 'dcm_subscribe',
         params: CommandParameters.new(:dcm_account_code => ["foo"], :dcm_topic_codes => ['XXX']),
         created_at: 1.days.ago,
         updated_at: 1.days.ago,
         keyword_id: 101,
         errors: [],
         :persisted? => true
    )
  end

  before do
    assign(:command, command)
    assign(:keyword, keyword)
    controller.stubs(:url_options).returns(:host => "test.host", :protocol => "http://", :_path_segments => {:action => "show", :controller => "commands", :keyword_id => 101, :id => 100}, :script_name => "")
  end

  it 'should work when valid' do
    render
    rendered.should be_json_for(command).
                      with_attributes(:name, :command_type).
                      with_objects(:params).
                      with_links('self' => keyword_command_path(keyword, command),
                                 'command_actions' => keyword_command_actions_path(keyword, command)
                    )
  end

  it 'should work when invalid' do
    command.stubs(:errors).returns(['whoops'])
    render
    rendered.should be_json_for(command).
                      with_attributes(:name, :command_type).
                      with_objects(:params).
                      with_links('self' => keyword_commands_path(keyword)).
                      with_errors
  end

end