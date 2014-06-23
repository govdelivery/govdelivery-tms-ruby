require 'spec_helper'

describe 'messages/create.rabl' do
  it 'renders errors' do
    sms_message = build(:sms_message, body: nil ).tap(&:valid?)
    assign(:message, sms_message)
    render
    rendered.should include("errors")
  end
end
