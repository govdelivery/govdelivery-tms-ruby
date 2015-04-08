require File.expand_path('../../../rails_helper', __FILE__)

describe 'keywords/show.rabl' do
  let(:keyword) do
    stub('keyword',
         to_param: '22',
         id: 22,
         class: Keyword,
         name: 'Test',
         response_text: 'GovAwesome',
         errors: [],
         persisted?: true)
  end


  it 'should work when valid' do
    assign(:keyword, keyword)
    render
    expect(rendered).to be_json_for(keyword).
                      with_attributes(:name, :response_text).
                      with_timestamps.
                      with_links('self' => keyword_path(keyword),
                                 'commands' => keyword_commands_path(keyword))
  end

  it 'should work when invalid' do
    assign(:keyword, keyword)
    keyword.stubs(:to_param).returns(nil)
    keyword.stubs(:persisted?).returns(false)
    render
    expect(rendered).to be_json_for(keyword).
                      with_attributes(:name, :response_text).
                      with_timestamps.
                      with_links(self: keywords_path)
  end
end
