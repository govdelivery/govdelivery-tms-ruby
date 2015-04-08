require 'rails_helper'

describe 'recipients/index.rabl' do
  let(:message) do
    stub('message', :id => 22, :class => SmsMessage)
  end
  let(:recipients) do
    5.times.map do |i|
      stub('recipient',
           :id => 11+i,
           :message_id => 22+i,
           :message => message,
           :formatted_phone => '+16125551212',
           :phone => '6125551212',
           :status => 'sent',
           :created_at => Time.now,
           :sent_at => Time.now,
           :error_message => nil,
           :completed_at => Time.now,
           :valid? => true)
    end
  end


  before do
    assign(:recipients, recipients)
    Rails.application.routes.url_helpers.stubs(:new_post_path).returns("this path isn't important")
    Rabl::Engine.any_instance.stubs(:url_for).returns('/fake')
    render
    @json = ActiveSupport::JSON.decode(rendered)
  end
  it 'should have one item' do
    expect(rendered).to have_json_type(Array)
    expect(rendered).to have_json_size(5)
  end
end
