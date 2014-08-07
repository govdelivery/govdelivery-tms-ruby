require 'rails_helper'

describe 'messages/index.rabl' do

  it "renders messages" do
    messages = build_stubbed_list(:sms_message, 3 )
    assign(:messages, messages)
    render
    rendered.should include('messages')
  end
end
