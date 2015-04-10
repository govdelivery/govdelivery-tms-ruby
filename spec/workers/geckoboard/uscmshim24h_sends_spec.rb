require 'rails_helper'

describe Geckoboard::Uscmshim24hSends do
  let(:account) { create(:account_with_sms) }

  subject { Geckoboard::Uscmshim24hSends.new }
  before do
    messages = create_list(:email_message, 3, account: account)
    messages.each do |message|
      message.created_at = message.created_at - 1.hour
      message.save
    end
  end

  it 'writes sending info for the past 24 hours in json format to disk' do
    end_time = Time.zone.now.beginning_of_hour
    start_time = end_time - 24.hours
    time_range = start_time.to_i...end_time.to_i
    times = time_range.step(1.hour).map { |t| Time.zone.at(t).in_time_zone('Eastern Time (US & Canada)').strftime('%H') }

    subject.expects(:write_to_file).with('name.json', {
      'item' => 23.times.collect { 0 } << 3,
      'settings' => {
        'axisx' => times,
        'axisy' => [0, 1, 3],
        'colour' => 'ff9900'
      }
    }.to_json)
    subject.perform(account.id, 'name')
  end
end
