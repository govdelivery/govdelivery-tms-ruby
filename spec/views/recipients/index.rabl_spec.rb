require 'spec_helper'

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
           :status => RecipientStatus::STATUS_SENT,
           :created_at => Time.now,
           :sent_at => Time.now,
           :error_message => nil,
           :completed_at => Time.now,
           :valid? => true)
    end
  end


  before do
    assign(:recipients, recipients)
    controller.stubs(:url_options).returns(:host => "test.host", :protocol => "http://", :_path_segments => {:action => "show", :controller => "recipients", :sms_id => message.id.to_s}, :script_name => "")
    render
    @json = ActiveSupport::JSON.decode(rendered)
  end
  it 'should have one item' do
    rendered.should have_json_type(Array)
    rendered.should have_json_size(5)
  end
end