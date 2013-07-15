require 'spec_helper'

describe SmsRecipient do
  subject {
    v = create(:sms_vendor)
    m = SmsMessage.new(:body => 'short body')
    a = Account.create(:name => 'account', :sms_vendor => v)
    u = User.create(:email => 'admin@get-endorsed-by-bens-mom.com', :password => 'retek01!')
    u.account = a
    m.account = a
    r = SmsRecipient.new
    r.message = m
    r.vendor = v
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
end
