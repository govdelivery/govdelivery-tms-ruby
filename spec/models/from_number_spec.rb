require 'rails_helper'

describe FromNumber do
  let(:account) { create(:account_with_voice) }

  context 'a valid from number' do
    before do
      account.from_numbers.create(is_default: true, phone_number: '8885551234')
    end
    it 'should not allow duplicate default numbers' do
      account.from_numbers.create(is_default: true, phone_number: '8885554321')
      expect(account.from_numbers.where(is_default: true).count).to eq(1)
    end

    it 'should not allow duplicate from numbers' do
      fa = account.from_numbers.create(phone_number: '8885551234')
      expect(fa.new_record?).to be true
      expect(fa.errors[:from_number]).not_to be_nil
    end
  end

  context 'with account and all addresses' do
    subject { account.from_numbers.build(phone_number: '5555555555') }
    it { is_expected.to be_valid }
  end

  context 'with account and from_number' do
    subject { account.from_numbers.build(phone_number: '8885556547') }
    it { is_expected.to be_valid }
  end

  context 'with no from_number' do
    subject { account.from_numbers.build }
    it { is_expected.not_to be_valid }
  end

  context 'with incoming voice messages' do
    subject do
      account.from_numbers.create(is_default: true, phone_number: '8885559876')
    end
    it 'should save valid voice message' do
      a = subject.incoming_voice_messages.build(say_text: 'poo', is_default: true)
      expect(a).to be_valid
    end

    it 'should return default voice message' do
      subject.save!
      old_message = subject.incoming_voice_messages.create(say_text: 'old message', is_default: true)
      old_message.created_at = Time.now - 1.hour
      old_message.save!
      subject.incoming_voice_messages.create(say_text: 'new message', is_default: true)

      expect(subject.default_incoming_voice_message.say_text).to eql('new message')
    end

    it 'should return latest voice message' do
      subject.save!
      subject.incoming_voice_messages.create(say_text: 'new message', is_default: false, expires_in: 200)
      subject.incoming_voice_messages.create(say_text: 'default message', is_default: true)

      expect(subject.voice_message.say_text).to eql('new message')
    end

    it 'should return default when message is expired' do
      subject.save!
      expired_message = subject.incoming_voice_messages.create(say_text: 'expired message', is_default: false, expires_in: 200)
      expired_message.created_at = Time.now - 24.hours
      expired_message.save!
      subject.incoming_voice_messages.create(say_text: 'default message', is_default: true)

      expect(subject.voice_message.say_text).to eql('default message')
    end
  end
end
