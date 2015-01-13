require 'rails_helper'

describe IncomingVoiceMessage do

  subject { build_stubbed(:incoming_voice_message) }
  it { should be_valid }

  it 'should be unexpired' do
    subject.is_expired?.should be false
  end

  it 'should expire' do
    message = build_stubbed(:incoming_voice_message, created_at: Time.now-7.days)
    message.is_expired?.should be true
  end
end
