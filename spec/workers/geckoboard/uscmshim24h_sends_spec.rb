require 'rails_helper'

describe Geckoboard::Uscmshim24hSends do
  let(:account){ create(:account_with_sms) }

  subject { Geckoboard::Uscmshim24hSends.new }
  before do
    create_list(:email_message, 3, account: account)
  end

  it 'puts calculates times in the Eastern time zone' do
    expect(subject.timezone).to eq("Eastern Time (US & Canada)")
  end

  it 'calculates message counts properly' do
    now       = Time.now
    end_time  = (now + 1.hour).beginning_of_hour
    start     = end_time - 24.hours
    date_range=start...end_time
    expect(subject.message_counts(date_range, account.id)).to eq({now.beginning_of_hour => 3})
  end

  it 'writes sending info for the past 24 hours in json format to disk' do
    times = (0..23).map {|t| sprintf '%02d', t}
    now = Time.now
    subject.expects(:write_to_file).with("name.json",{
      "item" => 23.times.collect{0} << 3,
      "settings" => {
        'axisx' => times.rotate(now.hour + 2), #wrap around to yesterday an hour from now in Eastern
        'axisy' => [0, 1, 3],
        'colour' => 'ff9900'
      }
    }.to_json)
    subject.perform(account.id, 'name')
  end
end