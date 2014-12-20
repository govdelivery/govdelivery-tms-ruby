require 'rails_helper'

describe VoiceRecipient do
  subject {
    v         = create(:voice_vendor)
    m         = VoiceMessage.new(:play_url => 'http://coffee.website.ninja')
    a         = Account.create(name: 'account', voice_vendor: v)
    u         = User.create(email: 'admin@get-endorsed-by-bens-mom.com', password: 'retek01!')
    u.account = a
    m.account = a
    r         = VoiceRecipient.new
    r.message = m
    r.vendor  = v
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

  describe 'stop retrying' do
    before do
      subject.phone = '6515551212'
      subject.status = 'sending'
      subject.message.max_retries = 2
      subject.save!
    end

    it 'can stop retrying on busy state' do
      subject.retry!('busy')
      subject.retry!('busy')
      subject.busy!('ackalacka',Time.now)
      subject.reload
      subject.vendor.should_not be_nil
      subject.completed_at.should_not be_nil
      subject.ack.should eq('ackalacka')
      subject.sent?.should be true
      subject.secondary_status.should eq('busy')
      subject.retries.should eq(2)
    end
  end

  describe "secondary statusi" do
    before do
      subject.phone = '6515551212'
      subject.status = 'sending'
      subject.save!
    end

    it 'can record busy states' do
      subject.busy!('ack',Time.now)
      subject.reload
      subject.vendor.should_not be_nil
      subject.completed_at.should_not be_nil
      subject.ack.should eq('ack')
      subject.sent?.should be true
      subject.secondary_status.should eq('busy')
    end

    it 'can record no answer states' do
      subject.no_answer!('ack',Time.now)
      subject.reload
      subject.vendor.should_not be_nil
      subject.completed_at.should_not be_nil
      subject.ack.should eq('ack')
      subject.sent?.should be true
      subject.secondary_status.should eq('no_answer')
    end

    it 'can record answering machine states' do
      subject.sent!('ack',:machine,Time.now)
      subject.reload
      subject.vendor.should_not be_nil
      subject.completed_at.should_not be_nil
      subject.ack.should eq('ack')
      subject.sent?.should be true
      subject.secondary_status.should eq('machine')
    end

    it 'can record real boy states' do
      subject.sent!('ack',:human,Time.now)
      subject.reload
      subject.vendor.should_not be_nil
      subject.completed_at.should_not be_nil
      subject.ack.should eq('ack')
      subject.sent?.should be true
      subject.secondary_status.should eq('human')
    end
  end

  describe 'retries' do
    before do
      subject.phone = '6515551212'
      subject.status = 'sending'
      subject.message.max_retries = 2
      subject.save!
    end

    it 'can retry on busy state' do
      expect { subject.busy!('ack',Time.now) }.to raise_error(Recipient::ShouldRetry)
      subject.reload
      subject.vendor.should_not be_nil
      subject.completed_at.should be_nil
      subject.ack.should be_nil
      subject.sent?.should be false
      subject.voice_recipient_retries.count.should == 1
    end

    it 'can retry on no answer state' do
      expect { subject.no_answer!('ack',Time.now) }.to raise_error(Recipient::ShouldRetry)
      subject.reload
      subject.vendor.should_not be_nil
      subject.completed_at.should be_nil
      subject.ack.should be_nil
      subject.sent?.should be false
      subject.reload.retries.should eq(1)
    end

    it 'can retry on failed state' do
      expect { subject.failed!('ack',Time.now) }.to raise_error(Recipient::ShouldRetry)
      subject.reload
      subject.vendor.should_not be_nil
      subject.completed_at.should be_nil
      subject.ack.should be_nil
      subject.sent?.should be false
      subject.secondary_status.should be_nil
      subject.reload.retries.should eq(1)
    end
  end

  describe 'timeout_expired' do
    let(:vendor) { create(:voice_vendor) }
    let(:account) { create(:account, voice_vendor: vendor, name: 'account') }
    let(:messages) {
      [1, 2].map { |x|
        m = create(:voice_message, account: account, play_url: "http://coffee.website.ninja/#{x}.wav")
        r = m.recipients.create!(phone: "1612555123#{x}")
        r.sending!('doo')
        m.ready!
        m.sending!
        m
      }
    }
    before do
      # do this in SQL to get as close to boundaries as possible
      messages[0].recipients.update_all("sent_at = sysdate - #{5.hours.to_i}/(24*60*60)")
      messages[1].recipients.update_all("sent_at = sysdate - #{3.hours.to_i}/(24*60*60)")
    end

    it 'only finds recipients in sending status' do
      expect(VoiceRecipient.timeout_expired.all).to eq(messages[0].recipients.all)
      messages.each { |m| m.recipients.update_all(status: 'new') }
      expect(VoiceRecipient.timeout_expired.all).to be_empty
    end
  end
end
