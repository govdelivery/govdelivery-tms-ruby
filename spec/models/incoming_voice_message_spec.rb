require 'rails_helper'

describe IncomingVoiceMessage do
  subject { build_stubbed(:incoming_voice_message) }
  it { is_expected.to be_valid }

  it 'should be unexpired' do
    expect(subject.is_expired?).to be false
  end

  it 'should expire' do
    message = build_stubbed(:incoming_voice_message, created_at: Time.now - 7.days)
    expect(message.is_expired?).to be true
  end
end
