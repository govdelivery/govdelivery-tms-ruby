require 'rails_helper'

describe 'message_types/show.rabl' do
  let(:message_type) {create(:message_type)}
  before do
    assign(:message_type, message_type)
  end

  it 'should work when valid' do
    render
    expect(rendered).to be_json_for(message_type)
      .with_attributes(:code, :label)
      .with_timestamps()
      .with_links('self' => message_type_path(message_type))
  end
end
