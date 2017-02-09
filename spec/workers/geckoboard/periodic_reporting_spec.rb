require 'rails_helper'

describe Geckoboard::PeriodicReporting do
  let(:account) {create(:account_with_sms)}
  let(:another_account) {create(:account_with_sms)}

  subject {Geckoboard::PeriodicReporting.new}

  it 'schedules other jobs' do
    messages = create_list(:email_message, 3, account: account)
    messages.each do |message|
      message.created_at = message.created_at - 1.hour
      message.save!
    end
    Conf.stubs(:allowed_geckoboard_accounts).returns([account.id])
    Geckoboard::EventsReporting.expects(:perform_async).times(1)
    subject.perform('EventsReporting', 'clicks_reporting', 'clicks')
  end

  it 'schedules other jobs when there is more than one allowed geckoboard account' do
    [account, another_account].each do |account|
      messages = create_list(:email_message, 3, account: account)
      messages.each do |message|
        message.created_at = message.created_at - 1.hour
        message.save!
      end
    end
    Conf.stubs(:allowed_geckoboard_accounts).returns([account.id, another_account.id])
    Geckoboard::EventsReporting.expects(:perform_async).times(2)
    subject.perform('EventsReporting', 'clicks_reporting', 'clicks')
  end
end
