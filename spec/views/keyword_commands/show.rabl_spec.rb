require File.expand_path('../../../rails_helper', __FILE__)

describe 'keyword_commands/show.rabl' do
  let(:keyword) { stub('Keyword', to_param: '101') }
  let(:command) do
    stub('Command',
         id: 100,
         to_param: '100',
         name: "MOMS",
         command_type: 'dcm_subscribe',
         params: CommandParameters.new(:dcm_account_code => ["foo"], :dcm_topic_codes => ['XXX']),
         params_hash: CommandParameters.new(:dcm_account_code => ["foo"], :dcm_topic_codes => ['XXX']).to_hash,
         created_at: 1.days.ago,
         updated_at: 1.days.ago,
         keyword_id: 101,
         errors: {},
         command_actions: [1],
         :persisted? => true
    )
  end

  before do
    assign(:command, command)
    assign(:keyword, keyword)
  end

  it 'should work when valid' do
    render
    rendered.should be_json_for(command).
                      with_attributes(:name, :command_type).
                      with_objects(:params).
                      with_links('self' => keyword_command_path(keyword, command),
                                 'keyword' => keyword_path(keyword),
                                 'command_actions' => keyword_command_actions_path(keyword, command)
                    )
  end

  it 'should work when invalid' do
    command.stubs(:errors).returns({:foo => 'whoops'})
    render
    rendered.should be_json_for(command).
                      with_attributes(:name, :command_type).
                      with_objects(:params).
                      with_links('self' => keyword_commands_path(keyword),
                                 'keyword' => keyword_path(keyword)).
                      with_errors
  end

end
