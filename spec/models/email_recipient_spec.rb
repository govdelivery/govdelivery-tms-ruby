require 'spec_helper'

describe EmailRecipient do
  subject {
    v = create_email_vendor
    m = EmailMessage.new(:body => 'short body', :subject => 'fuuu')
    m.stubs(:vendor).returns(v)
    a = v.accounts.create(:name => 'account', :email_vendor => v)
    u = User.create(:email => 'admin@example.com', :password => 'retek01!')
    u.account = a
    m.account = a
    r = m.recipients.build
    r.message = m
    r
  }

  its(:email) { should be_nil }
  it { should_not be_valid }

  context 'with an email' do
    before do
      subject.email='hi@man.com'
      subject.save!
    end
    context 'that is sent' do
      before do
        subject.sent!(Time.now)
      end
      it 'should update the record' do
        subject.reload
        subject.vendor.should_not be_nil
        subject.completed_at.should_not be_nil
        subject.status.should eq(RecipientStatus::SENT)
      end
    end
  end
end

