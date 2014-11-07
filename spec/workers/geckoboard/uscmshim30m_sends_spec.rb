require 'rails_helper'

describe Geckoboard::Uscmshim30mSends do
  let(:account){ create(:account_with_sms) }

  subject { Geckoboard::Uscmshim30mSends.new }
  before do
    messages = create_list(:email_message, 3, account: account)
    messages.each do |message|
      message.created_at = message.created_at - 1.minute
      message.save!
    end
  end

  it 'writes sending info for the past 30m in json format to disk' do
    end_time = Time.now.beginning_of_minute
    start_time = end_time - 30.minutes
    time_range = start_time.to_i...end_time.to_i
    times = time_range.step(1.minute).map {|t| Time.at(t).in_time_zone('Eastern Time (US & Canada)').strftime("%M")}
    subject.expects(:write_to_file).with("name.json",{
      "item" => 29.times.collect{0} << 3,
      "settings" => {
        'axisx' => times, #wrap around to yesterday an hour from now in Eastern
        'axisy' => [0, 1, 3],
        'colour' => 'ff9900'
      }
    }.to_json)
    subject.perform(account.id, 'name')
  end
end