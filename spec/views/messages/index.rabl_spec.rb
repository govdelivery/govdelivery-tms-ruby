require 'rails_helper'

describe 'messages/index.rabl' do
  it 'renders messages' do
    messages = build_stubbed_list(:sms_message, 3)
    assign(:messages, messages)
    render
    expect(rendered).to include('messages')
  end
end
