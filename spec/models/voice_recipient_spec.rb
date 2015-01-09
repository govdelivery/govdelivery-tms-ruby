require 'rails_helper'

describe VoiceRecipient do
  subject {
    m         = VoiceMessage.new(:play_url => 'http://coffee.website.ninja')
    a         = create(:account_with_voice)
    u         = User.create(email: 'admin@get-endorsed-by-bens-mom.com', password: 'retek01!')
    u.account = a
    m.account = a
    r         = VoiceRecipient.new
    r.message = m
    r.vendor  = a.voice_vendor
    r
  }

  its(:phone) { should be_nil }
  it { should_not be_valid } # validates_presence_of :phone

  describe "when phone is not a number" do
    before do
      subject.phone = 'invalid'
      subject.save!
    end
    it { should be_valid }
    its(:formatted_phone) { should be_nil }
  end

  describe "when phone starts with zero" do
    before do
      subject.phone = '0001112222'
      subject.save
    end
    it { should be_valid }
    its(:formatted_phone) { should be_nil }
  end

  describe "when phone has wrong # of digits" do
    before do
      subject.phone = '223'
      subject.save!
    end
    it { should be_valid }
    its(:formatted_phone) { should eq '+1223' }
  end

  describe "when phone is a non-string number" do
    before do
      subject.phone = 6125015456
      subject.save!
    end
  end

  describe "when phone is valid" do
    before do
      subject.phone = '6515551212'
    end

    it 'should persist formatted_phone if phone number is valid' do
      subject.save!
      subject.formatted_phone.should_not be_nil
    end

    it 'has an ack that is too long' do
      subject.ack = 'A'*257
      subject.should_not be_valid
    end

    it 'has an error message that is too long' do
      subject.error_message = 'A'*513
      subject.should be_valid
    end
  end

  describe 'retries' do
    before do
      subject.phone = '6515551212'
      subject.status = 'sending'
      subject.message.max_retries = 2
      subject.save!
    end

    context 'on first busy' do
      before do
        expect { subject.failed!('ack', nil, 'busy') }.to raise_error(Recipient::ShouldRetry)
      end

      it 'should retry if retries not exhausted' do
        subject.reload
        expect(subject.vendor).to_not be_nil
        expect(subject.completed_at).to be_nil
        expect(subject.ack).to be_nil
        expect(subject.sent?).to be false
        expect(subject.voice_recipient_attempts.where(ack: 'ack').count).to eq(1)
      end

      it 'should update ack on sending retry' do
        subject.sending!('ackretry')
        subject.reload
        expect(subject.vendor).to_not be_nil
        expect(subject.completed_at).to be_nil
        expect(subject.ack).to eq('ackretry')
        expect(subject.sent?).to be false
        expect(subject.voice_recipient_attempts.where(ack: 'ack').count).to eq(1)
      end

      context 'and subsequent success' do
        it 'should record it' do
          subject.sent!('ack1', nil, 'human')
          subject.reload
          expect(subject.vendor).to_not be_nil
          expect(subject.completed_at).to_not be_nil
          expect(subject.ack).to eq('ack1')
          expect(subject.sent?).to be true
          expect(subject.voice_recipient_attempts.where(ack: 'ack').count).to eq(1)
          expect(subject.voice_recipient_attempts.where(ack: 'ack1').count).to eq(1)
        end
      end

      context 'and a second no_answer or busy' do
        it 'should not retry and transition to failed state' do
          expect { subject.failed!('ack1', nil, :no_answer) }.to_not raise_error
          subject.reload
          expect(subject.vendor).to_not be_nil
          expect(subject.completed_at).to_not be_nil
          expect(subject.ack).to eq('ack1')
          expect(subject.failed?).to be true
          expect(subject.voice_recipient_attempts.where(ack: 'ack').count).to eq(1)
        end
      end
    end
  end
end
