require 'rails_helper'

describe VoiceMessagesController do
  let(:account) {create(:account_with_voice)}
  let(:user) {account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop')}
  let(:model) {VoiceMessage}
  let(:messages) do
    3.times.collect do |i|
      m = VoiceMessage.new(play_url: "http://com.com/#{i}",
                           recipients_attributes: [{phone: '800BUNNIES'}])
      m.created_at = i.days.ago
    end
  end

  before do
    sign_in user
  end

  it_should_create_a_message(play_url: 'http://com.com/')

  it_should_have_a_pageable_index(:messages)

  it_should_show_with_attributes(:from_number, :play_url, :recipient_detail_counts)
end
