require 'rails_helper'

describe Geckoboard::UscmshimEventsReporting do
  let(:account){ create(:account_with_sms) }

  subject { Geckoboard::UscmshimEventsReporting.new }

  before do
    create_list(:email_message, 3, account: account)
  end

  it 'writes aggregate click data for the past 24 hours in json format to disk' do
    times = (0..23).map {|t| sprintf '%02d', t}
    now = Time.now
    subject.expects(:write_to_file).with("name.json",{
      "item" => 24.times.collect{0},
      "settings" => {
        'axisx' => times.rotate(now.hour + 2), #wrap around to yesterday an hour from now in Eastern
        'axisy' => [0, 0, 0],
        'colour' => 'ff9900'
      }
    }.to_json)
    subject.perform('clicks', account.id, 'name')
  end

  it 'writes aggregate open data for the past 24 hours in json format to disk' do
    times = (0..23).map {|t| sprintf '%02d', t}
    now = Time.now
    subject.expects(:write_to_file).with("name.json",{
      "item" => 24.times.collect{0},
      "settings" => {
        'axisx' => times.rotate(now.hour + 2), #wrap around to yesterday an hour from now in Eastern
        'axisy' => [0, 0, 0],
        'colour' => 'ff9900'
      }
    }.to_json)
    subject.perform('opens', account.id, 'name')
  end
end