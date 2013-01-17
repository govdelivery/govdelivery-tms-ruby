require 'spec_helper'

describe 'recipients/show.rabl' do
  let(:message) do
    stub('message', :id => 22, :class => SmsMessage)
  end
  let(:recipient) do
    stub('recipient',
         :id => 11,
         :message_id => 22,
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


  before do
    assign(:recipient, recipient)
    controller.stubs(:url_options).returns(:host => "test.host", :protocol => "http://", :_path_segments => {:action => "show", :controller => "recipients", :sms_id => message.id.to_s}, :script_name => "")
    render
    @json = ActiveSupport::JSON.decode(rendered)
  end
  it 'should have one item' do
    @json.each do |k, v|
      if k=='_links'
        verify_links(v, recipient)
      elsif [:created_at, :sent_at, :completed_at].include?(k.to_sym)
        recipient.send(k).to_s(:json).should eq(Time.parse(v).to_s(:json))
      elsif [:formatted_phone, :phone, :status].include?(k.to_sym)
        recipient.send(k).should eq(v)
      else
        fail("Unrecognized JSON attribute #{k}: #{rendered}")
      end
    end
  end

  def verify_links(hsh, recipient)
    hsh['sms_message'].should eq(sms_path(22))
    hsh['self'].should eq(sms_recipient_path(22, 11))
  end
end