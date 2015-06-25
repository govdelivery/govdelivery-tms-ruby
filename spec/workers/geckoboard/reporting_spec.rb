require 'rails_helper'

describe Geckoboard::Reporting do
  let(:account) {create(:account_with_sms)}

  subject {Geckoboard::Reporting.new}

  it 'writes aggregate column info for the past 48 hours in json format to disk' do
    messages = create_list(:email_message, 3, account: account)
    messages.each do |message|
      message.created_at = message.created_at - 1.hour
      message.save!
    end
    subject.expects(:write_to_file).with('name.json', {
      'item' => [
        {'text' => '', 'value' => 3},
        {'text' => '', 'value' => 0}
      ]
    }.to_json)
    subject.perform(account.id, 'name', 'CREATED_AT')
  end
end
