require File.dirname(__FILE__) + '/../spec_helper'

describe VoiceMessagesController do

  let(:voice_vendor) { create_voice_vendor }
  let(:account) { voice_vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:model){VoiceMessage}
  let(:messages) do
    messages = 3.times.collect do |i|
      m = VoiceMessage.new(:play_url => "http://com.com/#{i}",
                      :recipients_attributes => [{:phone => "800BUNNIES"}])
      m.created_at = i.days.ago
    end
  end

  before do
    sign_in user
  end

  it_should_create_a_message({:play_url => 'http://com.com/'})

  it_should_have_a_pageable_index(:messages)

  it_should_show_with_attributes(:play_url)
end
