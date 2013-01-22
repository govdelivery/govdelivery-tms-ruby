require 'spec_helper'

describe 'keywords/show.rabl' do
  let(:keyword) do
    stub('keyword',
         :to_param => 22,
         :id => 22,
         :class => Keyword,
         :name => 'Test',
         :errors => [],
         :persisted? => true)
  end


  it 'should work when valid' do
    assign(:keyword, keyword)
    render
    rendered.should be_json_for(keyword).
                      with_attributes(:name).
                      with_timestamps.
                      with_links('self' => keyword_path(keyword),
                                 'commands' => keyword_commands_path(keyword))
  end

  it 'should work when invalid' do
    assign(:keyword, keyword)
    keyword.stubs(:to_param).returns(nil)
    keyword.stubs(:persisted?).returns(false)
    render
    rendered.should be_json_for(keyword).
                      with_attributes(:name).
                      with_timestamps.
                      with_links(:self => keywords_path)
  end
end
