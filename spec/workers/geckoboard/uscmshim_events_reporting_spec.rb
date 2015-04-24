require 'rails_helper'

describe Geckoboard::UscmshimEventsReporting do
  let(:account) {create(:account_with_sms)}
  let(:times) do
    end_time = Time.now.beginning_of_hour
    start_time = end_time - 24.hours
    time_range = start_time.to_i...end_time.to_i
    time_range.step(1.hour).map { |t| Time.at(t).in_time_zone('Eastern Time (US & Canada)').strftime('%H')}
  end

  subject {Geckoboard::UscmshimEventsReporting.new}

  before do
    messages = create_list(:email_message, 3, account: account)
    messages.each do |message|
      message.created_at = message.created_at - 1.hour
      message.save!
    end
  end

  it 'writes aggregate click data for the past 24 hours in json format to disk' do
    subject.expects(:write_to_file).with('name.json', {
      'item' => 24.times.collect {0},
      'settings' => {
        'axisx' => times,
        'axisy' => [0, 0, 0],
        'colour' => 'ff9900'
      }
    }.to_json)
    subject.perform('clicks', account.id, 'name')
  end

  it 'writes aggregate open data for the past 24 hours in json format to disk' do
    subject.expects(:write_to_file).with('name.json', {
      'item' => 24.times.collect {0},
      'settings' => {
        'axisx' => times,
        'axisy' => [0, 0, 0],
        'colour' => 'ff9900'
      }
    }.to_json)
    subject.perform('opens', account.id, 'name')
  end
end
