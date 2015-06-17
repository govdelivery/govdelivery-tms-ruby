require 'rails_helper'

describe 'messages/create.rabl' do
  it 'renders errors' do
    sms_message = build(:sms_message, body: nil).tap(&:valid?)
    assign(:message, sms_message)
    render
    expect(rendered).to include('errors')
    expect(rendered).to include('id')
  end
end
