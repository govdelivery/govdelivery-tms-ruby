require 'rails_helper'

describe Geckoboard::PeriodicReporting do
  let(:account) {create(:account_with_sms)}

  subject {Geckoboard::PeriodicReporting.new}

  it 'schedules other jobs' do
    messages = create_list(:email_message, 3, account: account)
    messages.each do |message|
      message.created_at = message.created_at - 1.hour
      message.save!
    end
    Conf.stubs(:allowed_geckoboard_accounts).returns([account.id])
    Geckoboard::EventsReporting.expects(:perform_async).times(1)
    subject.perform('EventsReporting', account.id, 'name', 'clicks')
  end
end
